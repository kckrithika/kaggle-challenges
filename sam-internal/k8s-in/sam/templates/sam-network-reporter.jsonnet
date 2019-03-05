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
                            "--logtostderr=true",
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
