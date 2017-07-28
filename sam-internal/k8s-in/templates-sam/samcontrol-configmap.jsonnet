local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samcontrol",
      namespace: "sam-system",
    },
    data: {
      "config.json": std.toString(import "../configs-sam/samcontrol-config.jsonnet")
    }
} else "SKIP"
