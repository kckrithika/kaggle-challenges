local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=COMMON",
                                     "-watchdogFrequency=5s",
                                     "-alertThreshold=20m",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=336h"],
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
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            {
                                mountPath: "/hostproc",
                                name: "procfs-volume",
                            },
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    {
                        hostPath: {
                            path: "/proc",
                        },
                        name: "procfs-volume",
                    },
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                ],
            },
            metadata: {
                labels: {
                    app: "watchdog-common",
                    apptype: "monitoring",
                    daemonset: "true",
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
    metadata+: {
        labels: {
            name: "watchdog-common",
        } + configs.ownerLabel.sam,
        name: "watchdog-common",
    },
}
