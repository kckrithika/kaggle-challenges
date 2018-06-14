local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
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
}
