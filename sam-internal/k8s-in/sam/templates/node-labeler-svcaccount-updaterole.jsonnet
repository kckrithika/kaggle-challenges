local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "node-labeler-update",
  },
  rules: [
  {
    apiGroups: ["*"],
    resources: ["nodes"],
    verbs: ["*"],
    },
],
} else "SKIP"
