local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samapp-controller",
      namespace: "sam-system",
    },
    data: {
      "samapp-controller-config.json": std.toString(import "configs/samapp-controller-config.jsonnet"),
    },
} else "SKIP"
