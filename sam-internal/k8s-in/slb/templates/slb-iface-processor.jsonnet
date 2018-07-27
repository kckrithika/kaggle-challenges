local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-iface-processor" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-iface-processor" };

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
                    configs.cert_volume,
                    slbconfigs.cleanup_logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                ]),
                containers: [
                    slbshared.slbIfaceProcessor(slbports.slb.slbNodeApiIfaceOverridePort),
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorIfaceLivenessProbeOverridePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiIfaceOverridePort),
                    slbshared.slbLogCleanup,
                ],
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

                                    ],
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
