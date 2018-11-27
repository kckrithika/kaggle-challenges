local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet");
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1380 then configs.deploymentBase("slb") {

      metadata: {
          labels: {
              name: "slb-fred",
          } + configs.ownerLabel.slb,
          name: "slb-fred",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-fred",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-fred",
                        image: slbimages.hypersdn,
                        command: std.prune([
                                     "/sdn/slb-fred",
                                     "--serviceName=" + "slb-fred",
                                     "--log_dir=" + slbconfigs.logsDir,
                                 ]),

                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
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
                                    ],
                                }],
                            },
                            topologyKey: "kubernetes.io/hostname",
                        }],
                    },
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [{
                                matchExpressions: [{
                                    key: "slb-service",
                                    operator: "NotIn",
                                    values: ["slb-ipvs"],
                                }],
                            }],
                        },
                    },
                },
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
