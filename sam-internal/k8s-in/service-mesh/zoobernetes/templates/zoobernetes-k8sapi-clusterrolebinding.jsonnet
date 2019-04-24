local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "serviceentries-readwrite-binding",
    namespace: "user-nsail",
    labels: {
      app: "zoobernetes",
    },
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "zoobernetes-service-account",
          namespace: "user-nsail",
         },
   ],
   roleRef: {
            kind: "ClusterRole",
            name: "zoobernetes-serviceentries-readwrite",
            apiGroup: "rbac.authorization.k8s.io",
        },
} else "SKIP"
