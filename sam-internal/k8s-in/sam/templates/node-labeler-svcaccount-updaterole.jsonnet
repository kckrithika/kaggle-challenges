local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "node-labeler-update",
    namespace: "sam-system",
  },
  rules: [
  {
    apiGroups: ["rbac.authorization.k8s.io"],
    resources: ["nodes"],
    verbs: ["*"],
    },
],
} else "SKIP"
