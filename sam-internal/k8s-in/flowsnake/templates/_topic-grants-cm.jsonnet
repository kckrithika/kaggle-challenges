local ajna_topic_auth = import "ajna_topic_auth.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled then
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
} else "SKIP"
