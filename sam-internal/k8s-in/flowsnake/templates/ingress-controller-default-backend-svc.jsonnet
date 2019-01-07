{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "default-http-backend",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                port: 80,
                protocol: "TCP",
                targetPort: 8080,
            },
        ],
        selector: {
            app: "default-http-backend",
        },
        sessionAffinity: "None",
        type: "ClusterIP",
    },
}
