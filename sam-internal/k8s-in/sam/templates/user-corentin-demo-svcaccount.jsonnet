local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "demo",
    namespace: "user-cdebains",
  },
} else "SKIP"
