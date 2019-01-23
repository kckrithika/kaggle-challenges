local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "madkub_injector");

if enabled then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "madkub-injector",
        namespace: "flowsnake",
    },
    spec: {
        ports: [{
            port: 443,
            targetPort: 8443
        }],
        selector: {
            app: "madkub-injector",
        },
    }
} else "SKIP"
