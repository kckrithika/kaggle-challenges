local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "RoleBinding",
  metadata: {
    name: "nsail-binding",
    namespace: "user-nsail",
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "zoobernetes",
          namespace: "user-nsail",
         },
   ],
   roleRef: {
            kind: "Role",
            name: "serviceentries-readwrite",
            apiGroup: "rbac.authorization.k8s.io",
        },
} else "SKIP"
