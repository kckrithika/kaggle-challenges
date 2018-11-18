local deplName = "slb-vpod-nginx";
local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.deplName };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.deplName };
local slbports = import "slbports.jsonnet";

if configs.estate == "vpod" then configs.deploymentBase("slb") {
metadata: {
        labels: {
            name: $.deplName,
        } + configs.ownerLabel.slb,
        name: $.deplName,
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: $.deplName,
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: std.prune([
                    slbconfigs.logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                ]),
                containers: [
                    slbshared.slbNginxConfig(deleteLimitOverride=0, vipInterfaceName="eth0"),
                    slbshared.slbNginxProxy(slbimages.slbnginx),
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
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
