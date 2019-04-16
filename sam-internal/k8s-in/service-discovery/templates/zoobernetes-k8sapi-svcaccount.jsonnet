local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "zoobernetes",
    namespace: "z9s-default",
  },
} else "SKIP"
