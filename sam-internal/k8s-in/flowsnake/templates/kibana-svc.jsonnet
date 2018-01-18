{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "kibana",
        namespace: "flowsnake",
        labels: {
            component: "kibana",
        },
    },
    spec: {
        type: "NodePort",
        selector: {
            component: "kibana",
        },
        ports: [
            {
                name: "http",
                port: 5601,
                protocol: "TCP",
                nodePort: 32003,
            },
        ],
    },
}
