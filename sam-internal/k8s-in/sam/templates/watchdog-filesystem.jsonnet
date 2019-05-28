local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-filesystem",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=FILESYSTEM",
                                     "-watchdogFrequency=600s",
                                     "-alertThreshold=900s",
                                     "-maxUptimeSampleSize=5",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.filesystem_watchdog_args
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=336h"],
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                            {
                                mountPath: "/data",
                                name: "data-volume",
                            },
                            {
                                mountPath: "/home",
                                name: "home-volume",
                            },
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
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
                ],
            },
            metadata: {
                labels: {
                    name: "watchdog-filesystem",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata+: {
        labels: {
            name: "watchdog-filesystem",
        } + configs.ownerLabel.sam,
        name: "watchdog-filesystem",
    },
}
