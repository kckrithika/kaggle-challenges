local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "version-mapping",
        namespace: "flowsnake",
    },
    data: {
        "version-mapping.properties": std.manifestIni(flowsnakeimage.version_mapping),
    },
}
