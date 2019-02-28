local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "default",
    namespace: "user-cdebains",
  },
} else "SKIP"
