local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
{
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
        name: "flowsnake-ldap",
        namespace: "flowsnake",
    },
    type: "Opaque",
    data: {
        "service-username": std.base64("minikube@sfdc"),
        "service-password": std.base64("nopassword"),
    },
} else "SKIP"
