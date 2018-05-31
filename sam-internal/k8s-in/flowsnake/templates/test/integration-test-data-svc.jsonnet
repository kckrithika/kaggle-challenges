local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if std.objectHas(flowsnake_images.feature_flags, "integration_test_data") then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "flowsnake-test-data",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "k80",
                port: 80,
            },
        ],
        selector: {
            app: "flowsnake-test-data",
        },
    },
} else "SKIP"
