local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-dns-register" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-dns-register" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-dns-register" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

local certDirs = ["cert3"];
local roleBasedSecretArgs = [
    "--keyfile=/cert3/client/keys/client-key.pem",
    "--certfile=/cert3/client/certificates/client.pem",
    "--cafile=/cert3/ca/cabundle.pem",
];

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
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
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },

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
                      ] + madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes()),
                      containers: [
                                      {
                                          name: "slb-dns-register-processor",
                                          image: slbimages.hypersdn,
                                          command: [
                                                       "/sdn/slb-dns-register",
                                                       "--path=" + slbconfigs.configDir,
                                                       "--ddi=" + slbconfigs.ddiService,
                                                   ] + roleBasedSecretArgs
                                                   + [
                                                       "--metricsEndpoint=" + configs.funnelVIP,
                                                       "--log_dir=" + slbconfigs.logsDir,
                                                       configs.sfdchosts_arg,
                                                       "--subnet=" + slbconfigs.subnet,
                                                       "--client.serverPort=" + portconfigs.slb.slbNodeApiDnsOverridePort,
                                                       "--client.serverInterface=lo",
                                                   ]
                                                   + (
                                                       if slbimages.hypersdn_build >= 1258 then [
                                                           "--restrictedSubnets=" + slbconfigs.publicSubnet + "," + slbconfigs.reservedIps,
                                                       ] else []
                                                   )
                                                   + (if slbflights.explicitDeleteLimit then ["--maxDeleteEntries=" + slbconfigs.perCluster.maxDeleteCount[configs.estate]] else [])
                                                   + slbflights.getNodeApiClientSocketSettings(slbconfigs.configDir),
                                          volumeMounts: configs.filter_empty([
                                              configs.maddog_cert_volume_mount,
                                              configs.cert_volume_mount,
                                              slbconfigs.slb_config_volume_mount,
                                              slbconfigs.logs_volume_mount,
                                              configs.sfdchosts_volume_mount,
                                          ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
                                      },
                                      slbshared.slbConfigProcessor(portconfigs.slb.slbConfigProcessorDnsLivenessProbeOverridePort),
                                      slbshared.slbCleanupConfig,
                                      slbshared.slbLogCleanup,
                                      slbshared.slbNodeApi(portconfigs.slb.slbNodeApiDnsOverridePort, true),
                                      madkub.madkubRefreshContainer(certDirs),
                                  ]
                                  + slbflights.getManifestWatcherIfEnabled()
                                  + (if slbflights.cnameRegisterEnabled then [
                                         {
                                             name: "slb-cname-register",
                                             image: slbimages.hypersdn,
                                             command: [
                                                 "/sdn/slb-cname-register",
                                                 "--ddi=" + slbconfigs.ddiService,
                                                 "--metricsEndpoint=" + configs.funnelVIP,
                                                 "--log_dir=" + slbconfigs.logsDir,
                                                 configs.sfdchosts_arg,
                                                 "--client.socketDir=" + slbconfigs.configDir,
                                                 "--client.dialSocket=true",
                                             ] + roleBasedSecretArgs,
                                             volumeMounts: configs.filter_empty([
                                                 configs.maddog_cert_volume_mount,
                                                 configs.cert_volume_mount,
                                                 slbconfigs.slb_config_volume_mount,
                                                 slbconfigs.logs_volume_mount,
                                                 configs.sfdchosts_volume_mount,
                                             ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
                                         },
                                     ] else []),
                      nodeSelector: (if slbflights.dnsRegisterPodFloat then { pool: slbconfigs.slbEstate } else { "slb-dns-register": "true" }),
                      initContainers: [
                          madkub.madkubInitContainer(certDirs),
                      ],
                  }
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
