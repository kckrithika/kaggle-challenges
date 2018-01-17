{
    apiVersion: "extensions/v1beta1",
    kind: "Ingress",
    metadata: {
        name: "fleet-service-ingress",
        namespace: "flowsnake",
        annotations: {
            "ingress.kubernetes.io/rewrite-target": "/",
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
