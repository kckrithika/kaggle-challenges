local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "zoobernetes-serviceentries-readwrite",
    namespace: "discovery",
    labels: {
      app: "zoobernetes",
    },
  },
  rules: [
  {
    apiGroups: ["*"],
    resources: ["namespaces", "services", "serviceentries"],
    verbs: ["*"],
    },
],
} else "SKIP"
