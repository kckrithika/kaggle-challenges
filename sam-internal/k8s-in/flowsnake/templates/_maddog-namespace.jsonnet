local flowsnakeconfigmap = import "flowsnake_configmap.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.maddog_enabled then
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
        data: std.toString(flowsnakeconfigmap.maddog_namespace),
    },
}
