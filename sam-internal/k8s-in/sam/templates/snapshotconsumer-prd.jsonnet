local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshotconsumer-prd",
        } + configs.ownerLabel.sam,
        name: "snapshotconsumer-prd",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshotconsumer-prd",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshotconsumer-prd",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [configs.containerWithKubeConfigAndMadDog {
                    name: "snapshotconsumer-prd",
                    image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshotconsumer-prd.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=3",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                        {
                            mountPath: "/var/mysqlPwd",
                            name: "mysql",
                            readOnly: true,
                        },
                    ],
                }],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshotconsumer-prd"),
                    {
                        secret: {
                            secretName: "mysql-pwd",
                        },
                        name: "mysql",
                    },
                ],
                hostNetwork: true,
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
