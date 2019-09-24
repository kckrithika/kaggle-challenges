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
                      volumes: configs.filter_empty([
                          configs.maddog_cert_volume,
                          configs.cert_volume,
                          slbconfigs.slb_config_volume,
                          slbconfigs.logs_volume,
                          configs.sfdchosts_volume,
                          slbconfigs.slb_volume,
                          configs.kube_config_volume,
                          slbconfigs.cleanup_logs_volume,
                          slbconfigs.proxyconfig_volume,
                          slbconfigs.reservedips_volume,
                      ] + madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes()),
                      containers: [
                                      {
                                          name: "slb-dns-register",
                                          image: (if configs.estate == "prd-sam" then "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/hammondpang/hyperslb:hammondpang" else slbimages.hyperslb),
                                          command: [
                                                       "/sdn/slb-dns-register",
                                                       "--path=" + slbconfigs.configDir,
                                                       "--ddi=" + slbconfigs.ddiService,
                                                   ] + roleBasedSecretArgs
                                                   + [
                                                       "--commonoptions.hostname=$(NODE_NAME)",
                                                       "--commonoptions.metricsendpoint=" + configs.funnelVIP,
                                                       "--log_dir=" + slbconfigs.logsDir,
                                                       configs.sfdchosts_arg,
                                                       "--subnet=" + slbconfigs.subnet,
                                                       "--client.serverPort=" + portconfigs.slb.slbNodeApiDnsOverridePort,
                                                       "--client.serverInterface=lo",
                                                       (
                                                            if std.length(slbconfigs.reservedIps) > 0 then
                                                                "--restrictedSubnets=" + slbconfigs.publicSubnet + "," + slbconfigs.reservedIps
                                                            else
                                                                "--restrictedSubnets=" + slbconfigs.publicSubnet
                                                       ),
                                                       "--maxDeleteEntries=" + slbconfigs.perCluster.maxDeleteCount[configs.estate],
                                                       // We can't use the full prefix limit space because sdn can also advertise IPs for docker. We subtract 2 as a safety margin.
                                                       "--vipLimit=" + (slbconfigs.perCluster.prefixLimit[configs.estate] - 2),
                                                   ]
                                                   + slbconfigs.getNodeApiClientSocketSettings(),
                                          volumeMounts: configs.filter_empty([
                                              configs.maddog_cert_volume_mount,
                                              configs.cert_volume_mount,
                                              slbconfigs.slb_config_volume_mount,
                                              slbconfigs.logs_volume_mount,
                                              configs.sfdchosts_volume_mount,
                                              slbconfigs.reservedips_volume_mount,
                                          ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
                                      } + configs.ipAddressResourceRequest,
                                      slbshared.slbConfigProcessor(portconfigs.slb.slbConfigProcessorDnsLivenessProbeOverridePort),
                                      slbshared.slbCleanupConfig,
                                      slbshared.slbLogCleanup,
                                      slbshared.slbNodeApi(portconfigs.slb.slbNodeApiDnsOverridePort, true),
                                      madkub.madkubRefreshContainer(certDirs),
                                      slbshared.slbManifestWatcher(),
                                       {
                                           name: "slb-cname-register",
                                           image: slbimages.hyperslb,
                                           command: [
                                                       "/sdn/slb-cname-register",
                                                       "--ddi=" + slbconfigs.ddiService,
                                                       "--log_dir=" + slbconfigs.logsDir,
                                                       configs.sfdchosts_arg,
                                                       "--client.socketDir=" + slbconfigs.configDir,
                                                       "--client.dialSocket=true",
                                                       "--commonoptions.metricsendpoint=" + configs.funnelVIP,
                                                       "--commonoptions.hostname=$(NODE_NAME)",
                                                       "--deletelimits.maxDeleteLimit=20",
                                                     ]
                                                     + roleBasedSecretArgs,
                                           volumeMounts: configs.filter_empty([
                                               configs.maddog_cert_volume_mount,
                                               configs.cert_volume_mount,
                                               slbconfigs.slb_config_volume_mount,
                                               slbconfigs.logs_volume_mount,
                                               configs.sfdchosts_volume_mount,
                                           ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
                                           env: [
                                               slbconfigs.node_name_env,
                                           ],
                                       },
                                  ],
                      nodeSelector: { pool: slbconfigs.slbEstate },
                      initContainers: [
                          madkub.madkubInitContainer(certDirs),
                      ],
                  } + slbconfigs.getGracePeriod()
                    + slbconfigs.getDnsPolicy(),

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
