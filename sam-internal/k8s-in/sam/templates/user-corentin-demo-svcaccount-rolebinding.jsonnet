local configs = import "config.jsonnet";
if configs.estate == "" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "RoleBinding",
  metadata: {
    name: "default-binding",
    namespace: "user-cdebains",
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "demo",
          namespace: "user-cdebains",
         },
   ],
   roleRef: {
            kind: "Role",
            name: "deployment-reader",
            apiGroup: "rbac.authorization.k8s.io",
        },
} else "SKIP"
