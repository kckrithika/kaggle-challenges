local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "casam-clusterrole",
    namespace: "core-on-sam-sp2",
  },
  rules: [
  {
    apiGroups: ["*"],
    resources: [ "pods","deployments"],
    verbs: ["*"],
    },
],
} else "SKIP"
