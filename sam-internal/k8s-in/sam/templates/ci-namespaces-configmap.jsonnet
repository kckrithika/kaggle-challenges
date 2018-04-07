local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
