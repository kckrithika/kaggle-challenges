local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-canary-passthrough-host-network",
        } + configs.ownerLabel.slb,
        name: "slb-canary-passthrough-host-network",
        namespace: "sam-system",
    },
    spec+: {
        replicas: if configs.estate == "prd-samtest" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-passthrough-host-network",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary-passthrough-host-network",
                        image: slbimages.hypersdn,
                        command: [
                                     "/sdn/slb-canary-service",
                                     "--serviceName=slb-canary-passthrough-host-network",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=" + portconfigs.slb.canaryServicePassthroughHostNetworkPort,
                                 ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: portconfigs.slb.canaryServicePassthroughHostNetworkPort,
                                },
                                initialDelaySeconds: 5,
                                periodSeconds: 3,
                            },
                        }
                        else {}
                    ),
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + slbflights.getDnsPolicy() + (
                if configs.estate == "prd-sdc" then {
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
                        nodeAffinity: {
                            requiredDuringSchedulingIgnoredDuringExecution: {
                                nodeSelectorTerms: [
                                    {
                                        matchExpressions: [
                                            {
                                                key: "slb-service",
                                                operator: "NotIn",
                                                values: ["slb-ipvs"],
                                            },
                                        ] + (
                                            if configs.estate == "prd-sdc" then
                                                [
                                                    {
                                                        key: "illumio",
                                                        operator: "NotIn",
                                                        values: ["a", "b"],
                                                    },
                                                ] else []
                                        ),
                                    },
                                ],
                            },
                        },
                    },
                } else {}
            ),
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
