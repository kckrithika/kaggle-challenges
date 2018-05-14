local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phase == "1" || slbimages.phase == "2" || slbimages.phase == "3" then { dirSuffix:: "slb-realsvrcfg" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + (if slbimages.phase == "1" || slbimages.phase == "2" || slbimages.phase == "3" then { dirSuffix:: "slb-realsvrcfg", configProcessorLivenessPort:: slbports.slb.slbConfigProcessorRealSvrLivenessProbeOverridePort, nodeApiPort:: slbports.slb.slbNodeApiRealSvrOverridePort } else {});

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-realsvrcfg",
        },
        name: "slb-realsvrcfg",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-realsvrcfg",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.sbin_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                ] + (if slbimages.phase == "1" || slbimages.phase == "2" || slbimages.phase == "3" then [
                    slbconfigs.slb_config_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    slbconfigs.cleanup_logs_volume,
                ] else [])),
                containers: [
                    slbshared.slbRealSvrCfg,
                ] + (if slbimages.phase == "1" || slbimages.phase == "2" || slbimages.phase == "3" then [
                    slbshared.slbConfigProcessor,
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi,
                    slbshared.slbLogCleanup,
                ] else []),
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                        {
                                            key: "pool",
                                            operator: "In",
                                            values: [configs.estate],
                                        },

                                    ],
                                },
                            ] + if configs.kingdom == "prd" then [{
                                matchExpressions: [
                                    {
                                        key: "master",
                                        operator: "In",
                                        values: ["true"],
                                    },
                                ],
                            }] else [],
                        },
                    },
                },
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "20%",
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
