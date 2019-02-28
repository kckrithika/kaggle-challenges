local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "RoleBinding",
  metadata: {
    name: "default-binding",
    namespace: "user-cdebains",
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "default",
          namespace: "user-cdebains",
         },
   ],
   roleRef: {
            kind: "Role",
            name: "deployment-reader",
            apiGroup: "rbac.authorization.k8s.io/v1beta1",
        },
} else "SKIP"
