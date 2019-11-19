local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if (configs.estate == "prd-samtest") then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sloopds",
                        resources: {
                            requests: {
                                cpu: "1",
                                memory: "10Gi",
                            },
                            limits: {
                                cpu: "1",
                                memory: "10Gi",
                            },
                        },
                        args: [
                            "--config=/sloopconfig/sloop.yaml",
                        ],
                        command: [
                            "/sloop",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/sloop:thargrove-20191114_170822-c2c0a76",
                        volumeMounts: [
                            {
                                name: "sloop-data",
                                mountPath: "/data/",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/sloopconfig/",
                            },
                        ],
                        ports: [
                            {
                                containerPort: portconfigs.sloop.sloop,
                                protocol: "TCP",
                            },
                        ],
                    },
                ],
                volumes+: [
                    {
                        hostPath: {
                            path: "/data/sloop-data",
                        },
                        name: "sloop-data",
                    },
                    {
                        configMap: {
                            name: "sloop",
                        },
                        name: "sloopconfig",
                    },
                ],
                nodeSelector: {
                    master: "true",
                    "kubernetes.io/hostname": "shared0-samtestkubeapi3-1-prd.eng.sfdc.net",
                },
            },
            metadata: {
                labels: {
                    app: "sloopds",
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
            name: "sloopds",
        } + configs.ownerLabel.sam,
        name: "sloopds",
    },
} else "SKIP"
