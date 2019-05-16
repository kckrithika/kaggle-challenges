local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "host-repair-aggregator",
        } + configs.ownerLabel.sam,
        name: "host-repair-aggregator",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "host-repair-aggregator",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "host-repair-aggregator",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [configs.containerWithKubeConfigAndMadDog {
                    name: "host-repair-aggregator",
                    image: samimages.hypersam,
                    command: [
                        "/sam/host-repair-aggregator",
                        "--config=/config/host-repair-aggregator.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=0",
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
                } + configs.ipAddressResourceRequest],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.config_volume("host-repair-aggregator"),
                    configs.cert_volume,
                    {
                        name: "mysql",
                        secret: {
                            defaultMode: 420,
                            secretName: "mysql-passwords",
                        },
                    },
                ],
                dnsPolicy: "ClusterFirst",
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
