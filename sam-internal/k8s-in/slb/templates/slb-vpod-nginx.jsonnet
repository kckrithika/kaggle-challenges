local deplName = "slb-vpod-nginx";
local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: deplName };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: deplName };
local slbports = import "slbports.jsonnet";
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: deplName };

if configs.kingdom == "vpod" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: deplName,
        } + configs.ownerLabel.slb,
        name: deplName,
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: deplName,
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: std.prune([
                    slbconfigs.logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.target_config_volume,
                    configs.cert_volume,
                    slbconfigs.customer_certs_volume,
                ] + madkub.madkubSlbCertVolumes(slbconfigs.nginxCertDirs)),
                containers: [
                    slbshared.slbNginxConfig(deleteLimitOverride=0, vipInterfaceName="eth0"),
                    slbshared.slbNginxProxy(slbimages.slbnginx),
                    slbshared.slbConfigProcessor(
                      configProcessorLivenessPort=slbports.slb.slbConfigProcessorLivenessProbePort,
                      proxyLabelSelector=deplName,
                      includeProxyConfigurationVolume=false,
                    ),
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, false),
                ],
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
