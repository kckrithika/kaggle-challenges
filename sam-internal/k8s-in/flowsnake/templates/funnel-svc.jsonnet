{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "funnel",
        namespace: "default",
    },
    spec: {
        type: "ExternalName",
        externalName: "ajna0-funnel1-0-prd.data.sfdc.net",
        ports: [
            {
                protocol: "TCP",
                port: 8080,
                targetPort: 8080,
            },
        ],
    },
}
