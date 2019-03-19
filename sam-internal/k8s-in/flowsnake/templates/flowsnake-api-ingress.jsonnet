local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
if flowsnakeconfig.is_v1_enabled then
{
    apiVersion: "extensions/v1beta1",
    kind: "Ingress",
    metadata: {
        name: "fleet-service-ingress",
        namespace: "flowsnake",
        annotations: {
            "ingress.kubernetes.io/rewrite-target": "/",
            "ingress.kubernetes.io/auth-tls-verify-client": "optional",
            "ingress.kubernetes.io/auth-tls-secret": "flowsnake/sfdc-ca",
            // This sets the maximum size of the chain presented by the client
            // See SSL_CTX_set_verify_depth: https://www.openssl.org/docs/man1.0.2/ssl/SSL_set_verify.html
            "ingress.kubernetes.io/auth-tls-verify-depth": "50",
        },
    },
    spec: {
        rules: [
            {
                http: {
                    paths: [
                        {
                            path: "/flowsnake",
                            backend: {
                                serviceName: "flowsnake-fleet-service",
                                servicePort: 8080,
                            },
                        },
                    ],
                },
            },
        ],
    },
} else "SKIP"
