local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "configmap-placeholder",
      namespace: "sam-system",
      labels: {
          "app": "configmap-placeholder"
      },
    },
    data: {
      "example.property.1": "hello",
      "example.property.2": "world",
    }
} else "SKIP"
