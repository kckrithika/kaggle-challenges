local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-node-os-stats",
        } + slbconfigs.ownerLabel,
        name: "slb-node-os-stats",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-node-os-stats",
                } + slbconfigs.ownerLabel,
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
                        image: slbimages.hypersdn,
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
                    },
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
