local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-bravo",
        } + configs.ownerLabel.slb,
        name: "slb-bravo",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-bravo",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-bravo",
                        image: slbimages.hypersdn,
                        [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: [
                                     "/sdn/slb-canary-service",
                                     "--serviceName=slb-bravo-svc",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=9090,9091,9092",
                                     "--tlsPorts=" + portconfigs.slb.canaryServiceTlsPort,
                                     "--privateKey=/var/slb/canarycerts/server.key",
                                 ]
                                 + (
                                     if configs.estate == "prd-sdc" then [
                                         "--publicKey=/var/slb/canarycerts/sdc.crt",
                                     ] else [
                                         "--publicKey=/var/slb/canarycerts/sam.crt",
                                     ]
                                 ),

                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: 9090,
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
