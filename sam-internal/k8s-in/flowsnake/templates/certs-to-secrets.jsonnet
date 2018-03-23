local configmap = import "flowsnake_configmap.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.maddog_enabled || !flowsnakeconfig.is_test_fleet then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "certs-to-secrets",
        namespace: "flowsnake",
    },
    data: {
        "master.config": std.toString(configmap.cert_secretizer_config),
    },
}
