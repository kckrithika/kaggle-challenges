local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "vpod" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "ci-namespaces",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "ci-namespaces.json": std.toString(import "configs/ci-namespaces.jsonnet"),
    },
} else "SKIP"
