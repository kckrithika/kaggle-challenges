local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-canary-proxy-http",
        } + configs.ownerLabel.slb,
        name: "slb-canary-proxy-http",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-proxy-http",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary-proxy-http",
                        image: slbimages.hypersdn,
                        [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: [
                                     "/sdn/slb-canary-service",
                                     "--serviceName=slb-canary-proxy-http",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=" + portconfigs.slb.canaryServiceProxyHttpPort,
                                     "--tlsPorts=443",
                                     "--privateKey=/var/slb/canarycerts/server.key",
                                         "--verbose=false",
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
                                    port: portconfigs.slb.canaryServiceProxyHttpPort,
                                },
                                initialDelaySeconds: 15,
                                periodSeconds: 10,
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
