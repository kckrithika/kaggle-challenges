local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local samimages = (import "../../sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");

# TODO: testing currently in PRD data, uncomment when test topic permissions fixed
# if flowsnake_config.is_test then {
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
                    image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/khogeland/hypersam:20180622_150001.1e3b6bf.dirty.khogeland-wsl0",
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
