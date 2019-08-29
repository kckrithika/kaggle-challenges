{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "serviceentries-readwrite-binding",
    namespace: "discovery",
    labels: {
      app: "zoobernetes",
    },
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "zoobernetessvcaccount",
      namespace: "discovery",
    },
  ],
  roleRef: {
    kind: "ClusterRole",
    name: "zoobernetes-serviceentries-readwrite",
    apiGroup: "rbac.authorization.k8s.io",
  },
}
