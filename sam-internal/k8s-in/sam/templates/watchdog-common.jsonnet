local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=COMMON",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=20m",
                        ]
                        + samwdconfig.shared_args
                        + (if configs.kingdom == "prd" then ["-emailFrequency=72h"] else ["-emailFrequency=24h"]),
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                          },
                        volumeMounts: configs.filter_empty([
                             configs.sfdchosts_volume_mount,
                             {
                                mountPath: "/hostproc",
                                name: "procfs-volume",
                             },
                             configs.config_volume_mount,
                        ])
                        + (
                            if configs.kingdom == "prd" || configs.kingdom == "frf" then
                                [configs.cert_volume_mount, configs.maddog_cert_volume_mount]
                            else []
                        ),
                    },
                ],
                volumes: configs.filter_empty([
                   configs.sfdchosts_volume,
                   {
                      hostPath: {
                         path: "/proc",
                      },
                      name: "procfs-volume",
                   },
                   configs.config_volume("watchdog"),
                ])
                + (
                    if configs.kingdom == "prd" || configs.kingdom == "frf" then
                        [configs.cert_volume, configs.maddog_cert_volume]
                    else []
                ),
            },
            metadata: {
                labels: {
                    app: "watchdog-common",
                    apptype: "monitoring",
                    daemonset: "true",
                },
               namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-common",
        },
        name: "watchdog-common",
    },
}
