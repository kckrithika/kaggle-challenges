local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "ci-namespaces",
        namespace: "sam-system",
    },
    data: {
        "ci-namespaces.json": std.toString(import "configs/ci-namespaces.jsonnet"),
    },
} else "SKIP"
