{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        namespace: "flowsnake",
        name: "elasticsearch-discovery",
        labels: {
            component: "elasticsearch",
        },
    },
    spec: {
        selector: {
            component: "elasticsearch",
        },
        ports: [
            {
                name: "transport",
                port: 9300,
                protocol: "TCP",
            },
        ],
    },
}
