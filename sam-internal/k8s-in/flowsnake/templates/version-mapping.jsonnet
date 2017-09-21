local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "version-mapping",
        namespace: "flowsnake"
    },
    data: {
        "version-mapping.properties": std.manifestPythonVars(flowsnakeimage.version_mapping)
    }
}
