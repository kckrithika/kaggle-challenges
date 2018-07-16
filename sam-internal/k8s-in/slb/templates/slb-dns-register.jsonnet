local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-dns-register" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-dns-register" };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-dns-register",
        },
        name: "slb-dns-register",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-dns-register",
                },
                namespace: "sam-system",
            },
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
                ]),
                containers: [
                    {
                        name: "slb-dns-register-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-dns-register",
                            "--path=" + slbconfigs.configDir,
                            "--ddi=" + slbconfigs.ddiService,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--cafile=" + configs.caFile,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ] + (if configs.estate == "prd-sam" then [
                                 "--maxDeleteEntries=500",
                             ] else [])
                          + (if slbimages.hypersdn_build >= 975 then [
                            "--subnet=" + slbconfigs.subnet,
                          ] else []),
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                    },
                    slbshared.slbConfigProcessor(portconfigs.slb.slbConfigProcessorDnsLivenessProbeOverridePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbLogCleanup,
                ] + (if slbimages.hypersdn_build >= 975 then [
                    slbshared.slbNodeApi(portconfigs.slb.slbNodeApiDnsOverridePort),
                ] else []),
                nodeSelector: {
                    "slb-dns-register": "true",
                },
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
