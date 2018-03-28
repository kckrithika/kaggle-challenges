local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_prod then
{
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
        name: "flowsnake-ldap",
        namespace: "flowsnake",
    },
    type: "Opaque",
    data: {
        "service-username": std.base64("prod@sfdc"),
        "service-password": std.base64("nopassword"),
    },
} else "SKIP"
