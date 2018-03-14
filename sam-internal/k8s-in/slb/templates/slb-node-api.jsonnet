local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if slbconfigs.slbInKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-node-api",
        },
        name: "slb-node-api",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-node-api",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                 ]),
                containers: [
                        {
                            name: "slb-node-api",
                            image: slbimages.hypersdn,
                            command: [
                                "/sdn/slb-node-api",
                                "--port=" + slbports.slb.slbNodeApiPort,
                                "--configDir=" + slbconfigs.configDir,
                                "--log_dir=" + slbconfigs.logsDir,
                            ],
                            volumeMounts: configs.filter_empty([
                                slbconfigs.slb_volume_mount,
                                slbconfigs.logs_volume_mount,
                             ]),
                        },
                ],
             } + if configs.estate == "prd-sdc" then {
                                               affinity: {
                                                                  nodeAffinity: {
                                                                                                                requiredDuringSchedulingIgnoredDuringExecution: {
                                                                                                                  nodeSelectorTerms: [
                                                                                                                    {
                                                                                                                          matchExpressions: [
                                                                                                                                              {
                                                                                                                                                 key: "pool",
                                                                                                                                                 operator: "In",
                                                                                                                                                 values: [configs.estate, configs.kingdom + "-slb"],
                                                                                                                                              },

                                                                                                                                            ],
                                                                                                                                            },
                                ],
                                },
                                },
                                },
                                            } else {},
        },
    },
} else "SKIP"
