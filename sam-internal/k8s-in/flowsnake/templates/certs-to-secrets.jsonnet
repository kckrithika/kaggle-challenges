local configmap = import "flowsnake_configmap.jsonnet";
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
