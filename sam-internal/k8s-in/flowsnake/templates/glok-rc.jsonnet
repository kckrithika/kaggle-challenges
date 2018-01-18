local flowsnakeimage = import "flowsnake_images.jsonnet";
local zookeeper = import "_zookeeper-rcs.jsonnet";
{
    apiVersion: "apps/v1beta1",
    kind: "StatefulSet",
    metadata: {
        labels: {
            name: "glok",
        },
        name: "glok",
        namespace: "flowsnake",
    },
    spec: {
        updateStrategy: {
            type: "RollingUpdate",
        },
        replicas: 3,
        serviceName: "glok-set",
        template: {
            metadata: {
                labels: {
                    name: "glok",
                    app: "glok",
                },
            },
            spec: {
                containers: [
                    {
                        name: "glok",
                        image: flowsnakeimage.glok,
                        imagePullPolicy: "Always",
                        env: [
                            {
                                name: "ZOOKEEPER_CONNECTION_STRING",
                                value: zookeeper.connection_string,
                            },
                            {
                                name: "KAFKA_PORT",
                                value: "9092",
                            },
                            {
                                name: "KAFKA_AUTO_CREATE_TOPICS_ENABLE",
                                value: "true",
                            },
                            {
                                name: "FLOWSNAKE_FLEET",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "name",
                                    },
                                },
                            },
                        ],
                        ports: [
                            {
                                containerPort: 9092,
                                name: "k9092",
                            },
                        ],
                        readinessProbe: {
                            tcpSocket: {
                                port: 9092,
                            },
                        },
                        livenessProbe: {
                            tcpSocket: {
                                port: 9092,
                            },
                            initialDelaySeconds: 180,
                        },
                    },
                ],
            },
        },
    },
}
