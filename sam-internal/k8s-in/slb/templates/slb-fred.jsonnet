local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phaseNum <= 3 then { dirSuffix:: "slb-fred" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-fred" };
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
                ] + (if slbimages.phaseNum <= 3 then
                         [slbconfigs.slb_volume, configs.sfdchosts_volume, slbconfigs.slb_config_volume, slbconfigs.cleanup_logs_volume]
                      else [])),
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
                                 ] + (if slbimages.phaseNum <= 3 then ["--monitorFrequency=1m"] else []),
                        volumeMounts: std.prune([
                            slbconfigs.logs_volume_mount,
                        ]),
                        env: [
                            slbconfigs.sfdcloc_node_name_env,
                        ],
                    } + configs.ipAddressResourceRequest,
                ] + (if slbimages.phaseNum <= 3 then [slbshared.slbLogCleanup] else []),
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
