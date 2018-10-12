local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
local flag_fs_matchlabels = std.objectHas(flowsnake_images.feature_flags, "fs_matchlabels");

{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "flowsnake-test-data",
        },
        name: "flowsnake-test-data",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: label_node.app,
            },
        },
        template: {
            metadata: {
                labels: {
                    app: "flowsnake-test-data",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "FlowsnakeTestData",
                } else {},
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "test-data",
                        image: flowsnake_images.test_data,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        ports: [
                            {
                                containerPort: 80,
                                name: "k80",
                            },
                        ],
                    },
                ],
            },
        },
    },
}
