{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "madkubserver",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "madkubapitls",
                port: 32007,
                targetPort: 32007,
            },
        ],
        selector: {
            service: "madkubserver",
        },
    },
}
