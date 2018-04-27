local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            service: "madkubserver",
        },
        name: "madkubserver",
        namespace: "flowsnake",
    },
    spec:
    {
        selector: {
            service: "madkubserver",
        },
        ports: [
            {
                name: "madkub-api-tls",
                port: 32007,
                targetPort: 32007,
            },
        ],
    } +
    (if flowsnakeconfig.is_minikube then {} else { clusterIP: "10.254.208.254" }),
    status: {
        loadBalancer: {},
    },
}
