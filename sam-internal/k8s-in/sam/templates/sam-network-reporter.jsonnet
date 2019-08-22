local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "sam-network-reporter",
                        image: samimages.hypersam,
                        command: [
                            "/sam/sam-network-reporter",
                            "--funnelEndpoint=" + configs.funnelVIP,
#                           "--logtostderr=true", # Logging is disabled because splunk team was complaining about too much traffic.
                            "--config=/config/sam-network-reporter.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                        ],
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                        ],
                        env+: [
                            {
                                name: "SFDCLOC_NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                        ],
                        ports: [
                            {
                                containerPort: 53353,
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                ] + [
                         configs.containerWithKubeConfigAndMadDog {
                            name: "sam-watchdog-connectivitylabeler",
                            image: samimages.hypersam,
                            command: [
                                "/sam/watchdog",
                                "-role=CONNECTIVITYLABELER",
                                "-watchdogFrequency=60s",
                                "-alertThreshold=300s",
                                "--config=/config/watchdog.json",
                                "--hostsConfigFile=/sfdchosts/hosts.json",
                                "-watchDogKind=" + $.kind,
                            ],
                            volumeMounts+: [
                                configs.sfdchosts_volume_mount,
                                configs.cert_volume_mount,
                                configs.watchdog_volume_mount,
                            ],
                            env+: [
                                {
                                    name: "SFDCLOC_NODE_NAME",
                                    valueFrom: {
                                        fieldRef: {
                                            fieldPath: "spec.nodeName",
                                        },
                                    },
                                },
                            ],
                            ports: [
                                {
                                    containerPort: 53353,
                                },
                            ],
                        } + configs.ipAddressResourceRequest,
                    ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                ]
                + [
                    {
                        configMap: {
                            name: "sam-network-reporter",
                        },
                        name: "config",
                    },
                    {
                        configMap: {
                            name: "watchdog",
                        },
                        name: "watchdogconfig",
                    },
                ],
            },
            metadata: {
                labels: {
                    name: "sam-network-reporter",
                    apptype: "control",
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
            name: "sam-network-reporter",
        } + configs.ownerLabel.sam,
        name: "sam-network-reporter",
    },
}
