local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.kingdom == "prd" || configs.kingdom == "xrd" then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
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
                            configs.config_volume_mount,
                        ]
                        #+ [{
                        #    mountPath: "/etc/kubernetes/kubeconfig-platform",
                        #        name: "kubeconfig",
                        #        readOnly: true,
                        #}]
                        ,
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
                                containerPort: 3333,
                                hostPort: 3333,
                            },
                        ],
                        resources+: configs.ipAddressResource,
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                ]
                + [
                    {
                        hostPath: {
                            path: "/manifests",
                        },
                        name: "sfdc-volume",
                    },
                    #{
                    #    hostPath: {
                    #        path: "/etc/kubernetes/kubeconfig-platform",
                    #    },
                    #    name: "kubeconfig",
                    #},
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
} else "SKIP"
