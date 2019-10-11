local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet");
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbports = import "slbports.jsonnet";

if slbconfigs.isSlbEstate && configs.estate != "prd-samtest" then configs.deploymentBase("slb") {

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
                volumes: std.prune([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-fred",
                        image: slbimages.hyperslb,
                        command: [
                                     "/sdn/slb-fred",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--commonoptions.metricsendpoint=" + configs.funnelVIP,
                                     "--commonoptions.hostname=$(NODE_NAME)",
                                     "--vipName=slb-canary-proxy-http.sam-system.%(estate)s.%(kingdom)s.slb.sfdc.net" % configs,
                                     "--port=%(canaryServiceProxyHttpPort)d" % slbports.slb,
                                 ],
                        volumeMounts: std.prune([
                            slbconfigs.logs_volume_mount,
                        ]),
                        env: [
                            slbconfigs.sfdcloc_node_name_env,
                        ],
                    } + configs.ipAddressResourceRequest,
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
