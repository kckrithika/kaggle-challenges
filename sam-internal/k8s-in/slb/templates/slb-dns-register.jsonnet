local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-dns-register" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-dns-register" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-dns-register" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

local certDirs = ["cert3"];

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-dns-register",
        } + configs.ownerLabel.slb,
        name: "slb-dns-register",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-dns-register",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            } + (if slbflights.roleBasedSecrets then {
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            } else {}),
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.slb_volume,
                    configs.kube_config_volume,
                    slbconfigs.cleanup_logs_volume,
                ] + (if slbflights.roleBasedSecrets then madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes() else [])),
                containers: [
                    {
                        name: "slb-dns-register-processor",
                        image: slbimages.hypersdn,
                        command: [
                                     "/sdn/slb-dns-register",
                                     "--path=" + slbconfigs.configDir,
                                     "--ddi=" + slbconfigs.ddiService,
                                 ] + (if slbflights.roleBasedSecrets then [
                                     "--keyfile=/cert3/client/keys/client-key.pem",
                                     "--certfile=/cert3/client/certificates/client.pem",
                                     "--cafile=/cert3/ca/cabundle.pem",
                                 ] else [
                                     "--keyfile=" + configs.keyFile,
                                     "--certfile=" + configs.certFile,
                                     "--cafile=" + configs.caFile,
                                 ]) + [
                                     "--metricsEndpoint=" + configs.funnelVIP,
                                     "--log_dir=" + slbconfigs.logsDir,
                                     configs.sfdchosts_arg,
                                     "--subnet=" + slbconfigs.subnet,
                                     "--client.serverPort=" + portconfigs.slb.slbNodeApiDnsOverridePort,
                                     "--client.serverInterface=lo",
                                 ]
                                 + (
                                     if slbimages.phaseNum <= 2 then [
                                         "--restrictedSubnets=" + slbconfigs.publicSubnet + "," + slbconfigs.reservedIps,
                                     ] else []
                                 )
                                 + (
                                    if configs.estate == "prd-sam" then [
                                        "--maxDeleteEntries=10",
                                        ] else []
                                    )
                                 + slbflights.getNodeApiClientSocketSettings(slbconfigs.configDir),
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ] + (if slbflights.roleBasedSecrets then madkub.madkubSlbCertVolumeMounts(certDirs) else [])),
                    },
                    slbshared.slbConfigProcessor(portconfigs.slb.slbConfigProcessorDnsLivenessProbeOverridePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbLogCleanup,
                    slbshared.slbNodeApi(portconfigs.slb.slbNodeApiDnsOverridePort, true),

                ] + (if slbflights.roleBasedSecrets then [madkub.madkubRefreshContainer(certDirs)] else []) + slbflights.getManifestWatcherIfEnabled(),
                nodeSelector: {
                    "slb-dns-register": "true",
                },
            } + (if slbflights.roleBasedSecrets then {
                initContainers: [
                    madkub.madkubInitContainer(certDirs),
                ],
} else {})
            + slbflights.getDnsPolicy(),

        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
