local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "Role",
  metadata: {
    name: "serviceentries-readwrite",
    namespace: "user-nsail",
  },
  rules: [
  {
    apiGroups: ["networking.istio.io"],
    resources: ["servicentries"],
    verbs: ["*"],
    },
],
} else "SKIP"
