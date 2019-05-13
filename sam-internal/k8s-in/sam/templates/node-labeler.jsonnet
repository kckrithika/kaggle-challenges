local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                serviceAccountName: "node-labeler-sa",
                serviceAccount: "node-labeler-sa",
                containers: [
                    {
                        image: samimages.hypersam,
                        name: "node-labeler",
                        command: configs.filter_empty([
                                     "/sam/node-labeler",
                                     "--config=/config/node-labeler-config.json",
                                 ]),
                        volumeMounts+: configs.filter_empty([
                            configs.config_volume_mount,
                            {
                                name: "etc-data",
                                mountPath: "/etc/sfdc-release",
                            },
                        ]),
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
                    },
                ],
                volumes+: configs.filter_empty([
                    configs.config_volume("node-labeler"),
                    {
                        name: "etc-data",
                        hostPath: {
                            path: "/etc/sfdc-release",
                        },
                    },
                ]),
            },
            metadata: {
                labels: {
                    app: "node-labeler",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
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
            name: "node-labeler",
        } + configs.ownerLabel.sam,
        name: "node-labeler",
        namespace: "sam-system",
    },
} else "SKIP"
