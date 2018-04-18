local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-proxy-http",
        },
        name: "slb-canary-proxy-http",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-proxy-http",
                },
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
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-proxy-http",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=" + portconfigs.slb.canaryServiceProxyHttpPort,
                            "--tlsPorts=443",
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
                                                              "slb-nginx-config-b",
                                                               "slb-nginx-config-a",
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
                                                                       values: ["slb-ipvs", "slb-nginx-a", "slb-nginx-b"],
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
    } + if slbimages.phase == "1" || slbimages.phase == "2" then {
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    } else {},
} else "SKIP"
