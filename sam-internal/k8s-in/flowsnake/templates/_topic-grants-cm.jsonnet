local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "ajna-topic-grants",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(flowsnakeauthtopic.topic_grants),
    },
}
