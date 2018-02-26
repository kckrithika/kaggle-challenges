local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
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
    spec: {
        clusterIP: "10.254.208.254",
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
    status: {
        loadBalancer: {},
    },
}
