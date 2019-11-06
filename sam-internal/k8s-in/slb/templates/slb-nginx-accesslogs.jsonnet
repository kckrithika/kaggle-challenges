local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phaseNum <= 1 then { dirSuffix:: "slb-nginx-accesslogs" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-nginx-accesslogs" };
local slbflights = import "slbflights.jsonnet";
local slbports = import "slbports.jsonnet";

if slbconfigs.isSlbEstate && slbflights.enableNginxAccessLogsAggregation then configs.deploymentBase("slb") {

      metadata: {
          labels: {
              name: "slb-nginx-accesslogs",
          } + configs.ownerLabel.slb,
          name: "slb-nginx-accesslogs",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-accesslogs",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: std.prune([
                    slbconfigs.logs_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                    ] + (if slbimages.phaseNum <= 1 then
                            [slbconfigs.slb_volume, configs.sfdchosts_volume, slbconfigs.slb_config_volume, slbconfigs.cleanup_logs_volume,]
                         else [])),
                containers: [
                    {
                        name: "slb-nginx-accesslogs",
                        image: slbimages.hyperslb,
                        command: [
                                     "/sdn/slb-nginx-accesslogs",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--httpTimeout=5m",
                                 ],

                        volumeMounts: std.prune([
                            slbconfigs.logs_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                            ]),
                        env: [
                            slbconfigs.node_name_env,
                            configs.kube_config_env,
                            ],
                        resources: {
                            limits: {
                                memory: "1Gi",
                            },
                        },
                    } + configs.ipAddressResourceRequest,
                ] + (if slbimages.phaseNum <= 1 then [slbshared.slbLogCleanup] else []),
            }
            + slbconfigs.slbEstateNodeSelector
            + slbconfigs.getGracePeriod()
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
