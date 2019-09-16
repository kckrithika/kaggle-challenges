local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sloop",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "prometheus.json": std.toString(import "configs/sloop-prometheus.jsonnet"),
        "sloop.yaml": (importstr "configs/sloop.yaml"),
    },
} else "SKIP"
