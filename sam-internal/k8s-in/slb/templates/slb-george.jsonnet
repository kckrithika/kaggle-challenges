local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet");
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if slbconfigs.isSlbEstate && slbflights.georgeEnabled then configs.deploymentBase("slb") {

      metadata: {
          labels: {
              name: "slb-george",
          } + configs.ownerLabel.slb,
          name: "slb-george",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-george",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: std.prune([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-george",
                        image: slbimages.hypersdn,
                        command: [
                                     "/sdn/slb-fred",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--commonoptions.metricsendpoint=" + configs.funnelVIP,
                                     "--commonoptions.hostname=$(NODE_NAME)",
                                     "--vipName=slb-canary-proxy-http.sam-system.prd-sdc.prd.slb.sfdc.net",
                                     "--port=9116",
                                     "--downloadSize=1",
                                     "--uploadSize=1",
                                 ],

                        volumeMounts: std.prune([
                            slbconfigs.logs_volume_mount,
                        ]),
                        env: [
                            slbconfigs.node_name_env,
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
                affinity: {
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
