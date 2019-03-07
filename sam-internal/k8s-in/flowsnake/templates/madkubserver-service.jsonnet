local flowsnake_config = import "flowsnake_config.jsonnet";
if flowsnake_config.madkub_enabled then
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
    (if flowsnake_config.is_minikube then {} else { clusterIP: "10.254.208.254" }),
    status: {
        loadBalancer: {},
    },
} else "SKIP"
