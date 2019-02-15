local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet");
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbports = import "slbports.jsonnet";

if slbconfigs.isSlbEstate && slbflights.tempDisableNginxAccesslogs then configs.deploymentBase("slb") {

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
                ]),
                containers: [
                    {
                        name: "slb-nginx-accesslogs",
                        image: slbimages.hyperslb,
                        command: [
                                     "/sdn/slb-nginx-accesslogs",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--k8sApiServer=" + "http://shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:40000/",
                                     "--httpTimeout=5m",
                                 ],

                        volumeMounts: std.prune([
                            slbconfigs.logs_volume_mount,
                        ]),
                        env: [
                            slbconfigs.node_name_env,
                        ],
                        resources: {
                            limits: {
                                memory: "1Gi",
                            },
                        },
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
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
