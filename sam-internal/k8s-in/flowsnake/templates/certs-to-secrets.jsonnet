{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "certs-to-secrets",
        namespace: "flowsnake",
    },
    data: {
        "master.config": std.toString(import "cert-secretizer-master-config.jsonnet"),
    },
}
