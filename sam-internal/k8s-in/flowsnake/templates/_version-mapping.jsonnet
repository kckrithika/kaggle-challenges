local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "version-mapping",
        namespace: "flowsnake",
    },
    data: {
        "version-mapping.properties": std.manifestIni(flowsnake_images.version_mapping),
    },
}
