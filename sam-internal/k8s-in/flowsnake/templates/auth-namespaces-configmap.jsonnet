local pki_auth = import "pki_auth.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "auth-namespaces",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(pki_auth.auth_namespaces),
    },
} else "SKIP"
