{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "glok",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "k9092",
                port: 9092,
            },
        ],
        selector: {
            app: "glok",
        },
    },
}
