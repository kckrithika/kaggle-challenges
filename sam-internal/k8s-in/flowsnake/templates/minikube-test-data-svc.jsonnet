local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "flowsnake-test-data",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "k80",
                port: 80,
            },
        ],
        selector: {
            app: "test-data",
        },
    },
} else "SKIP"
