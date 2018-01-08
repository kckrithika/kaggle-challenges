local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "flowsnake-logloader"
        },
        name: "flowsnake-logloader",
        namespace: "flowsnake"
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: "flowsnake-logloader"
            }
        },
        template: {
            metadata: {
                labels: {
                    name: "flowsnake-logloader",
                    app: "flowsnake-logloader"
                }
            },
            spec: {
                containers: [
                    {
                        name: "flowsnake-logloader",
                        image: flowsnakeimage.logloader,
                        imagePullPolicy: "Always",
                        env: [
                            {
                                name: "FLOWSNAKE_FLEET",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "name"
                                    }
                                }
                            },
                            {
                                name: "DOCKER_REGISTRY_URL",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "registry"
                                    }
                                }
                            },
                            {
                                name: "KUBERNETES_IMAGE_PULL_POLICY",
                                value: "Always"
                            }
                        ]
                    }
                ]
            }
        }
    }
}
