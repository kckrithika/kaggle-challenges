local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-passthrough-host-network",
        } + slbconfigs.ownerLabel,
        name: "slb-canary-passthrough-host-network",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-passthrough-host-network",
                } + slbconfigs.ownerLabel,
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
            } + (
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
                                            "slb-nginx-config-a",
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
                                        ],
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
