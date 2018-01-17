{
    apiVersion: "extensions/v1beta1",
    kind: "Ingress",
    metadata: {
        name: "kibana-ingress",
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
                            path: "/kibana-logs",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601,
                            },
                        },
                    ],
                },
            },
        ],
    },
}
