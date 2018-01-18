{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "glok-set",
        namespace: "flowsnake",
        labels: {
            app: "glok-set",
        },
    },
    spec: {
        clusterIP: "None",
        selector: {
            app: "glok",
        },
        ports: [
            {
                name: "k9092",
                port: 9092,
            },
        ],
    },
}
