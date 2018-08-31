local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "host-repair-aggregator",
        namespace: "sam-system",
    },
    data: {
        "host-repair-aggregator.json": std.toString(import "configs/host-repair-aggregator-config.jsonnet"),
    },
} else "SKIP"
