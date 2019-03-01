local configs = import "config.jsonnet";
if configs.estate == "" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "demo",
    namespace: "user-cdebains",
  },
} else "SKIP"
