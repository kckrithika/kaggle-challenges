local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "RoleBinding",
  metadata: {
    name: "serviceentries-readwrite-binding",
    namespace: "z9s-default",
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "zoobernetes",
          namespace: "z9s-default",
          apiGroup: "rbac.authorization.k8s.io"
         },
   ],
   roleRef: {
            kind: "Role",
            name: "serviceentries-readwrite",
            apiGroup: "rbac.authorization.k8s.io",
        },
} else "SKIP"
