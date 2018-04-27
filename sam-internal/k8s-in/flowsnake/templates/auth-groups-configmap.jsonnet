local deprecated_ldap_auth = import "deprecated_ldap_auth.jsonnet";
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
}
