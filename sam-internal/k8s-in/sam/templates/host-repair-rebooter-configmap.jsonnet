local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "host-repair-rebooter",
        namespace: "sam-system",
    },
    data: {
        "host-repair-rebooter.json": std.toString(import "configs/host-repair-rebooter-config.jsonnet"),
    },
} else "SKIP"
