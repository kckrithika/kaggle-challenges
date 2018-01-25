local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "prometheus",
      namespace: "sam-system",
    },
    data: {
      "prometheus.json": std.toString(import "configs/prometheus.jsonnet"),
    },
} else "SKIP"
