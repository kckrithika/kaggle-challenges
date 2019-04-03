local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local quota_enforcement = std.objectHas(flowsnake_images.feature_flags, "spark_application_quota_enforcement");

if quota_enforcement then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "spark-webhook",
        namespace: "flowsnake",
    },
    spec: {
        ports: [{
            port: 443,
            targetPort: 8443
        }],
        selector: {
			"app.kubernetes.io/name": "spark-operator",
        },
    }
} else "SKIP"
