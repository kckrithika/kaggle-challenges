{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "flowsnake-fleet-service",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "fs30001",
                port: 8080,
            },
        ],
        selector: {
            app: "flowsnake-fleet-service",
        },
        type: "NodePort",
    },
}
