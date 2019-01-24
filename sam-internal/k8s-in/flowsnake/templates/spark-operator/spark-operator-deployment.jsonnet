local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "spark_operator");

if enabled then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
      name: "spark-operator",
      namespace: "flowsnake",
      labels: {
        "app.kubernetes.io/name": "spark-operator",
        "app.kubernetes.io/version": "v2.4.0-v1beta1",
      },
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                "app.kubernetes.io/name": "spark-operator",
                "app.kubernetes.io/version": "v2.4.0-v1beta1",
            },
        },
        strategy: {
            type: "Recreate",
        },
        template: {
            metadata: {
                labels: {
                    "app.kubernetes.io/name": "spark-operator",
                    "app.kubernetes.io/version": "v2.4.0-v1beta1",
                },
            },
            spec: {
                serviceAccountName: "spark-operator",
                containers: [{
                    name: "spark-operator",
                    image: flowsnake_images.spark_operator,
                    imagePullPolicy: "Always",
                    command: ["/usr/bin/spark-operator"],
                    args: ["-logtostderr", "-v", "2"],
                }],
            },
        },
    },
} else "SKIP"
