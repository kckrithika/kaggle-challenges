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
                ]),
                containers: [
                    {
                        name: "slb-cleanup",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-cleanup",
                            "--period=1800s",
                            "--log_dir=" + slbconfigs.logsDir,
                        ]
                        + (
                          if configs.estate == "prd-sdc" then [
                            "--logsMaxAge=2d",
                          ] else [
                            "--logsMaxAge=48h",
                          ]
                        ),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                         ]),
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
