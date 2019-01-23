local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
        name: "test-qcai",
    },
} else "SKIP"
