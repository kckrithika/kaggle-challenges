local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = import "slbsharedservices.jsonnet";

if slbconfigs.slbInKingdom && slbimages.phaseNum > 1 then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-node-api",
        } + configs.ownerLabel.slb,
        name: "slb-node-api",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-node-api",
                    apptype: "control",
                    daemonset: "true",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiPort),
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
                                            values: [configs.estate, configs.kingdom + "-slb"],
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
