local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "default-http-backend",
        },
        name: "default-http-backend",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: "default-http-backend",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "default-http-backend",
                    app: "default-http-backend",
                },
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "default-http-backend",
                        image: flowsnakeimage.ingress_default_backend,
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 30,
                            timeoutSeconds: 5,
                        },
                        ports: [
                            {
                                containerPort: 8080,
                            },
                        ],
                        resources: {
                            limits: {
                                cpu: "10m",
                                memory: "20Mi",
                            },
                            requests: {
                                cpu: "10m",
                                memory: "20Mi",
                            },
                        },
                    },
                ],
            },
        },
    },
}
