local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.kingdom == "prd" || configs.kingdom == "xrd" then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithMadDog {
                containers: [
                    configs.containerWithMadDog {
                        name: "sam-network-reporter",
                        image: samimages.hypersam,
                        command: [
                            "/sam/sam-network-reporter",
                            "--funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                            "--logtostderr=true",
                            "--config=/config/sam-network-reporter.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                        ],
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_platform_volume_mount,
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
                                containerPort: 37373,
                                hostPort: 37373,
                            },
                        ],
                        resources+: configs.ipAddressResource,
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.kube_config_platform_volume,
                ]
                + [{
                    hostPath: {
                        path: "/manifests",
                    },
                    name: "sfdc-volume",
                }],
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
} else "SKIP"
