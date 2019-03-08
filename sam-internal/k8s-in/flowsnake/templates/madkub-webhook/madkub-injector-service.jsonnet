local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if flowsnake_config.madkub_enabled then
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
