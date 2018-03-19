local flowsnakeconfigmap = import "flowsnake_configmap.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "auth-namespaces",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(flowsnakeconfigmap.auth_namespaces),
    },
}
