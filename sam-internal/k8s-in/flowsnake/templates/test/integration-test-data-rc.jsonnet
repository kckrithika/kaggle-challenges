local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

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
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "FlowsnakeTestData",
                },
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
