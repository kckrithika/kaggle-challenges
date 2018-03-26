local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-filesystem",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=FILESYSTEM",
                                     "-watchdogFrequency=180s",
                                     "-alertThreshold=1h",
                                     "-maxUptimeSampleSize=5",
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=24h"],
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.config_volume_mount,
                            {
                                mountPath: "/data",
                                name: "data-volume",
                            },
                            {
                                mountPath: "/home",
                                name: "home-volume",
                            },
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                    {
                        hostPath: {
                            path: "/data",
                        },
                        name: "data-volume",
                    },
                    {
                        hostPath: {
                            path: "/home",
                        },
                        name: "home-volume",
                    },
                ]),
            },
            metadata: {
                labels: {
                    name: "watchdog-filesystem",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-filesystem",
        },
        name: "watchdog-filesystem",
    },
}
