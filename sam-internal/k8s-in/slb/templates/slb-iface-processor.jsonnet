local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phase == "1" then { dirSuffix:: "slb-iface-processor" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + (if slbimages.phase == "1" then { dirSuffix:: "slb-iface-processor", configProcessorLivenessPort:: slbports.slb.slbConfigProcessorIfaceLivenessProbeOverridePort, nodeApiPort:: slbports.slb.slbNodeApiIfaceOverridePort } else {});

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-iface-processor",
        },
        name: "slb-iface-processor",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-iface-processor",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.sbin_volume,
                ] + (if slbimages.phase == "1" then [
                    configs.cert_volume,
                    slbconfigs.cleanup_logs_volume,
                ] else [])),
                containers: [
                    slbshared.slbIfaceProcessor,
                ] + (if slbimages.phase == "1" then [
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
                                            values: if slbconfigs.slbInProdKingdom || configs.estate == "prd-sam" then [configs.kingdom + "-slb"] else [configs.estate],
                                        },

                                    ] + (if slbimages.phase == "1" then [
                                        {
                                                                                key: "slb-service",
                                                                                operator: "NotIn",
                                                                                values: ["slb-ipvs", "slb-ipvs-a"],
                                                                            },
                                    ] else []),
                                },
                            ] + if slbconfigs.isTestEstate then [{
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
