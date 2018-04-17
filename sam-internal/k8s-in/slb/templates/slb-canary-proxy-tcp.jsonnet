local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-proxy-tcp",
        },
        name: "slb-canary-proxy-tcp",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-proxy-tcp",
                },
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
                                           key: "illumio",
                                           operator: "NotIn",
                                           values: ["a", "b"],
                                     },
                                 ],
                              },
                         ],
                     },
                 },

              },
                containers: [
                    {
                        name: "slb-canary-proxy-tcp",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-proxy-tcp",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=" + portconfigs.slb.canaryServiceProxyTcpPort,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
