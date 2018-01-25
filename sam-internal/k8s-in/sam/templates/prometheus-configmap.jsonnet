local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "prometheus",
      namespace: "sam-system",
    },
    data: {
      "prometheus.cfg": std.toString(importstr "configs/prometheus.cfg"),
    },
} else "SKIP"
