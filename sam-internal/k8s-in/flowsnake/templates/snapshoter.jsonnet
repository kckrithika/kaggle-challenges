local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
local flag_fs_matchlabels = std.objectHas(flowsnake_images.feature_flags, "fs_matchlabels");

if flowsnake_config.snapshots_enabled then ({
    local label_node = self.spec.template.metadata.labels,
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
        [if flag_fs_matchlabels then "selector"]: {
            matchLabels: {
                name: label_node.name,
                apptype: label_node.apptype,
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshoter",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "Snapshoter",
                } else {},
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
                    image: flowsnake_images.snapshoter,
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
