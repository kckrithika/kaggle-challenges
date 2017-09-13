local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "sam-system",
    },
    data: {
      "watchdog.json": std.toString(import "configs/watchdog-config.jsonnet")
    }
} else "SKIP"
