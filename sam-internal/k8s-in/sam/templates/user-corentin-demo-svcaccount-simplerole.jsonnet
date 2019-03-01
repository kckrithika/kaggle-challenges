local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "Role",
  metadata: {
    name: "deployment-reader",
    namespace: "user-cdebains",
  },
  rules: [
  {
    apiGroups: ["*"],
    resources: ["pods", "pods/log", "deployments"],
    verbs: ["get", "list"],
    },
],
} else "SKIP"
