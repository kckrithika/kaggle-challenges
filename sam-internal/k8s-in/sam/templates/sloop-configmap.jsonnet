local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sloop",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "prometheus.json": std.toString(import "configs/sloop-prometheus.jsonnet"),
    },
} else "SKIP"
