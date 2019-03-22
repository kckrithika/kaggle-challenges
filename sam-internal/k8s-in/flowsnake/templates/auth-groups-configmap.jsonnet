local deprecated_ldap_auth = import "deprecated_ldap_auth.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "auth-groups",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(deprecated_ldap_auth.auth_groups),
    },
} else "SKIP"
