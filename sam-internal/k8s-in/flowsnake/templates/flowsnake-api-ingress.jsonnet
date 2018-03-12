{
    apiVersion: "extensions/v1beta1",
    kind: "Ingress",
    metadata: {
        name: "fleet-service-ingress",
        namespace: "flowsnake",
        annotations: {
            "ingress.kubernetes.io/rewrite-target": "/",
            "ingress.kubernetes.io/auth-tls-verify-client": "optional",
            "ingress.kubernetes.io/auth-tls-secret": "flowsnake/flowsnake-tls",
            "ingress.kubernetes.io/auth-tls-verify-depth": "1",
            //"ingress.kubernetes.io/auth-tls-error-page": "/nice-try-red-team",
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
}
