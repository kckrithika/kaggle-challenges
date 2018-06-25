local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");

if estate == "prd-data-flowsnake" then ({
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshotconsumer",
        },
        name: "snapshotconsumer",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshotconsumer",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshotconsumer",
                },
                namespace: "flowsnake",
            },
            spec: {
                containers: [{
                    name: "snapshotconsumer",
                    # From https://git.soma.salesforce.com/dva-transformation/sam/tree/support-replication-controllers
                    image: flowsnake_images.snapshot_consumer,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshotconsumer.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=3",
                    ],
                    volumeMounts: configs.filter_empty([
                        configs.sfdchosts_volume_mount,
                        configs.maddog_cert_volume_mount,
                        configs.cert_volume_mount,
                        configs.kube_config_volume_mount,
                        configs.config_volume_mount,
                        {
                            mountPath: "/var/mysqlPwd",
                            name: "mysql",
                            readOnly: true,
                        },
                    ]),
                    env: [
                        configs.kube_config_env,
                    ],
                }],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("snapshotconsumer"),
                    {
                        secret: {
                            secretName: "mysql-pwd",
                        },
                        name: "mysql",
                    },
                ]),
                hostNetwork: true,
            },
        },
    },
}) else "SKIP"
