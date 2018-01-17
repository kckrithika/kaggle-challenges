local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "flowsnake-test-data",
        },
        name: "flowsnake-test-data",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: "flowsnake-test-data",
            },
        },
        template: {
            metadata: {
                labels: {
                    app: "flowsnake-test-data",
                },
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "test-data",
                        image: "minikube/flowsnake-test-data:minikube",
                        imagePullPolicy: "Never",
                        ports: [
                            {
                                containerPort: 80,
                                name: "k80",
                            },
                        ],
                    },
                ],
            },
        },
    },
} else "SKIP"
