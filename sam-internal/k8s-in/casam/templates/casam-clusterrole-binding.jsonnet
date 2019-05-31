local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "casam-clusterrolebinding",
    namespace: "core-on-sam-sp2",
  },
  subjects: [
        {
          kind: "ServiceAccount",
          name: "casamserviceaccount",
          namespace: "core-on-sam-sp2",
         },
   ],
   roleRef: {
            kind: "ClusterRole",
            name: "casam-clusterrole",
            apiGroup: "rbac.authorization.k8s.io",
        },
} else "SKIP"
