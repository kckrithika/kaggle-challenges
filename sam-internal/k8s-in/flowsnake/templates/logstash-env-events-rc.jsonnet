local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local zookeeper = import "zookeeper-rcs.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube_small then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "logstash-env-events",
        namespace: "flowsnake",
        labels: {
            name: "logstash-env-events",
            app: "logstash-env-events",
        },
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: "logstash-env-events",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "logstash-env-events",
                    app: "logstash-env-events",
                },
                namespace: "flowsnake",
            },
            spec: {
                containers: [
                    {
                        name: "logstash",
                        image: flowsnakeimage.logstash,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
                        env: [
                            {
                                name: "KAFKA_TOPIC",
                                value: "flowsnake-environment-events",
                            },
                            {
                                name: "ELASTICSEARCH_INDEX",
                                value: "flowsnake-environment-events",
                            },
                            {
                                name: "ELASTICSEARCH_DOCUMENT_TYPE",
                                value: "event",
                            },
                            {
                                name: "ZOOKEEPER_CONNECTION_STRING",
                                /*value: zookeeper.connection_string*/
                                value: "zookeeper-0.zookeeper-set:2181,zookeeper-1.zookeeper-set:2181,zookeeper-2.zookeeper-set:2181",
                            },
                        ],
                    },
                ],
            },
        },
    },
}
