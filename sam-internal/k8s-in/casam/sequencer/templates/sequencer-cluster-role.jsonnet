local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "casam-sequencer-clusterrole",
    namespace: "core-on-sam-sp2",
  },
  rules: [
  {
    apiGroups: ["*"],
    resources: [ "pods"],
    verbs: ["get","list"],
    },
],
} else "SKIP"
