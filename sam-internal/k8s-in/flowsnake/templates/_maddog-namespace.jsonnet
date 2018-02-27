local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        // TODO: rename
        name: "maddog-namespaces",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(flowsnakeauthtopic.maddog_namespace),
    },
}
