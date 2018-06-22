local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local samimages = (import "../../sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");

# TODO: testing currently in PRD data, uncomment when test topic permissions fixed
# if flowsnake_config.is_test then ({
if estate == "prd-data-flowsnake" then ({
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshoter",
        },
        name: "snapshoter",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshoter",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshoter",
                },
                namespace: "flowsnake",
            },
            spec: {
                containers: [{
                    command: [
                        "/sam/snapshoter",
                        "--config=/config/snapshoter.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "--v=4",
                        "--alsologtostderr",
                    ],
                    volumeMounts: configs.filter_empty([
                        configs.sfdchosts_volume_mount,
                        configs.maddog_cert_volume_mount,
                        configs.cert_volume_mount,
                        configs.kube_config_volume_mount,
                        configs.config_volume_mount,
                    ]),
                    env: [
                        configs.kube_config_env,
                    ],
                    livenessProbe: {
                        httpGet: {
                            path: "/",
                            port: 9095,
                        },
                        initialDelaySeconds: 20,
                        periodSeconds: 20,
                        timeoutSeconds: 20,
                    },
                    image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/khogeland/hypersam:20180622_150001.1e3b6bf.dirty.khogeland-wsl0",
                    name: "snapshoter",
                }],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("snapshoter"),
                ]),
                hostNetwork: true,
            },
        },
    },
}) else "SKIP"
