local cert_secretizer = import "cert_secretizer.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_v1_enabled then {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "certs-to-secrets",
        namespace: "flowsnake",
    },
    data: {
        "master.config": std.toString(cert_secretizer.cert_secretizer_config),
    },
} else "SKIP"
