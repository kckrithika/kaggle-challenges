local ajna_topic_auth = import "ajna_topic_auth.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "ajna-topic-grants",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(ajna_topic_auth.topic_grants),
    },
}
