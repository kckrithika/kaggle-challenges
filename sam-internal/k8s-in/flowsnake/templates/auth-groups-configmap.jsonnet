local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "auth-groups",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(flowsnakeauthtopic.auth_groups),
    },
}
