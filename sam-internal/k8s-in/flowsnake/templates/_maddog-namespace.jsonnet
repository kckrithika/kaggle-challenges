local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "maddog-namespaces",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(flowsnakeauthtopic.maddog_namespace),
    },
}
