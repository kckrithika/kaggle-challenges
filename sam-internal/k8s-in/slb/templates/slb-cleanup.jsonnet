local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-cleanup",
        },
        name: "slb-cleanup",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-cleanup",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
               volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                ] + if configs.estate == "prd-sdc" then [
                                                      configs.sfdchosts_volume,
                                                   ] else []),
                containers: [
                    {
                        name: "slb-cleanup",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-cleanup",
                            "--period=1800s",
                            "--logsMaxAge=48h",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--filesDirToCleanup=" + slbconfigs.logsDir,
                            "--shouldSkipServiceRecords=false",
                            "--shouldNotDeleteAllFiles=false",
                        ] + if configs.estate == "prd-sdc" then [
                                                                              configs.sfdchosts_arg,
                                                                           ] else [],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                         ] + if configs.estate == "prd-sdc" then [
                                                                               configs.sfdchosts_volume_mount,
                                                                            ] else []),
                         env: [
                            configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    }
                    + (
                    if configs.estate == "prd-sdc" then {
                    livenessProbe: {
                      exec: {
                            command: [
                                       "test",
                                       "`find /slb-cleanup-heartbeat -mmin -.5`",
                                     ],
                      },
                      initialDelaySeconds: 15,
                      periodSeconds: 15,
                    },
                    }
                    else {}
                    ),
                ],
            },
        },
    },
} else "SKIP"
