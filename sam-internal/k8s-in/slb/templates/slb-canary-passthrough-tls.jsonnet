local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-canary-passthrough-tls",
        } + configs.ownerLabel.slb,
        name: "slb-canary-passthrough-tls",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-passthrough-tls",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                affinity: {
                    podAntiAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: [{
                            labelSelector: {
                                matchExpressions: [{
                                    key: "name",
                                    operator: "In",
                                    values: [
                                        "slb-ipvs",
                                        "slb-ipvs-a",
                                        "slb-ipvs-b",
                                        "slb-vip-watchdog",
                                    ],
                                }],
                            },
                            topologyKey: "kubernetes.io/hostname",
                        }],
                    },
                } + (if configs.estate == "prd-sdc" then {
                         nodeAffinity: {
                             requiredDuringSchedulingIgnoredDuringExecution: {
                                 nodeSelectorTerms: [
                                     {
                                         matchExpressions: [
                                             {
                                                 key: "illumio",
                                                 operator: "NotIn",
                                                 values: ["a", "b"],
                                             },
                                         ],
                                     },
                                 ],
                             },
                         },
                     } else {}),
                containers: [
                    {
                        name: "slb-canary-passthrough-tls",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-passthrough-tls",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=" + portconfigs.slb.canaryServicePassthroughTlsPort,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + slbflights.getDnsPolicy(),
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
