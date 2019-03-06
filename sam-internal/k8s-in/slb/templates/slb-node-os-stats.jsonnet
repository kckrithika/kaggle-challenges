local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-node-os-stats",
        } + configs.ownerLabel.slb,
        name: "slb-node-os-stats",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-node-os-stats",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                        {
                                            key: "slb-service",
                                            operator: "In",
                                            values: ["slb-nginx-b", "slb-ipvs"],
                                        },
                                    ],
                                },
                            ],
                        },
                    },
                },

                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    slbconfigs.proc_volume,
                ]),
                containers: [
                    {
                        name: "slb-node-os-stats",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-node-os-stats",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.proc_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    } + configs.ipAddressResourceRequest,
                ],
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
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
