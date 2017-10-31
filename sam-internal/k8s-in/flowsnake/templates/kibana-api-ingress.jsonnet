{
    apiVersion: "extensions/v1beta1",
    kind: "Ingress",
    metadata: {
        name: "kibana-api-ingress",
        namespace: "flowsnake"
    },
    spec: {
        rules: [
            {
                http: {
                    paths: [
                        {
                            path: "/app/kibana",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601
                            }
                        },
                        {
                            path: "/bundles",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601
                            }
                        },
                        {
                            path: "/status",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601
                            }
                        },
                        {
                            path: "/plugins",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601
                            }
                        },
                        {
                            path: "/elasticsearch",
                            backend: {
                                serviceName: "kibana",
                                servicePort: 5601
                            }
                        }
                    ]
                }
            }
        ]
    }
}
