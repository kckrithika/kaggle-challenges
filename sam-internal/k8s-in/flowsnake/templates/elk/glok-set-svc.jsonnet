local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled && !std.objectHas(flowsnake_images.feature_flags, "glok_retired") then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "glok-set",
        namespace: "flowsnake",
        labels: {
            app: "glok-set",
        },
    },
    spec: {
        clusterIP: "None",
        selector: {
            app: "glok",
        },
        ports: [
            {
                name: "k9092",
                port: 9092,
            },
        ],
    },
} else "SKIP"
