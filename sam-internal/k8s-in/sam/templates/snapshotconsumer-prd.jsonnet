local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshotconsumer",
        } + configs.ownerLabel.sam,
        name: "snapshotconsumer-prd",
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
                namespace: "sam-system",
            },
            spec: {
                containers: [{
                    name: "snapshotconsumer",
                    image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshotconsumer-prd.json",
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
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
