local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if std.objectHas(flowsnake_images.feature_flags, "integration_test_data") then
{
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
                app: "flowsnake-test-data",
            },
        },
        template: {
            metadata: {
                labels: {
                    app: "flowsnake-test-data",
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
} else "SKIP"
