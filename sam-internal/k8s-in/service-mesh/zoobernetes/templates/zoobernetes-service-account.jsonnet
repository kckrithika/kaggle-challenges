local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "zoobernetessvcaccount",
    namespace: "discovery",
    labels: {
      app: "zoobernetes",
    },
  },
} else "SKIP"
