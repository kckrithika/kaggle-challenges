local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local zookeeper = import "_zookeeper-rcs.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local elk = import "elastic_search_logstash_kibana.jsonnet";
if flowsnakeconfig.is_v1_enabled && !std.objectHas(flowsnake_images.feature_flags, "glok_retired") then
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
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
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
                                //Explicit string required due to Jsonnet -> YAML -> JSON:
                                //https://github.com/kubernetes/kubernetes/issues/2763
                                value: std.format("%d", elk.kafka_partitions),
                            },
                            {
                                name: "DEFAULT_REPLICATION_FACTOR",
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
} else "SKIP"
