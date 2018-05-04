local pki_auth = import "pki_auth.jsonnet";
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
}
