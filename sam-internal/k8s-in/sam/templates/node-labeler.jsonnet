local configs = import "config.jsonnet";

local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

local utils = import "util_functions.jsonnet";

if !utils.is_pcn(configs.kingdom) then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
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
                serviceAccount: "node-labeler-sa",
                serviceAccountName: "node-labeler-sa",
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
