local configs = import "config.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "switchboard",
    namespace: "core-on-sam-sp2",
    labels: {
      app: "switchboard",
    },
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "switchboard",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "switchboard-service-account",
      namespace: "core-on-sam-sp2",
    },
  ],
}
