local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "funnel",
        namespace: "default",
    },
    spec: {
        type: "ExternalName",
        externalName: flowsnakeconfig.funnel_vip,
        ports: [
            {
                protocol: "TCP",
                port: 8080,
                targetPort: 8080,
            },
        ],
    },
}
