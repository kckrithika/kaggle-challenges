local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "prometheus-rm",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "prometheus-rm.json": std.toString(import "configs/prometheus-rm.jsonnet"),
    },
} else "SKIP"
