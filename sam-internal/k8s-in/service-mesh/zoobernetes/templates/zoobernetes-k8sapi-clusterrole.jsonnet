local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "zoobernetes-serviceentries-readwrite",
  },
  rules: [
  {
    apiGroups: ["networking.istio.io"],
    resources: ["servicentries"],
    verbs: ["*"],
    },
],
} else "SKIP"
