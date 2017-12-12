local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "fds-sfms",
      namespace: "sam-system",
    },
    data: {
      "fds.json": std.toString(import "configs/fds-sfms-config.jsonnet"),
    },
} else "SKIP"
