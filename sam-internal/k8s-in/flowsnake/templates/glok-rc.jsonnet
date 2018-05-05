local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local zookeeper = import "_zookeeper-rcs.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local elk = import "elk.jsonnet";
if std.objectHas(flowsnake_images.feature_flags, "simplify_elk_replicas") then
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
        replicas: elk.kafka_replicas,
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
                        image: flowsnake_images.glok,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
                                name: "NUM_PARTITIONS",
                                value: elk.kafka_partitions,
                            },
                            {
                                name: "DEFAULT_REPLICATION_FACTOR",
                                value: elk.kafka_replicas,
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
} else {
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
        replicas: elk.kafka_replicas,
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
                        image: flowsnake_images.glok,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
                                name: "NUM_PARTITIONS",
                                //TODO: there's no reason not to just use the int directly here
                                value: std.format("%d", elk.kafka_partitions),
                            },
                            {
                                name: "DEFAULT_REPLICATION_FACTOR",
                                //TODO: there's no reason not to just use the int directly here
                                value: std.format("%d", elk.kafka_replicas),
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
