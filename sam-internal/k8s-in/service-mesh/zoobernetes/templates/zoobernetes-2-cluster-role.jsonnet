{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "zoobernetes-serviceentries-readwrite",
    namespace: "discovery",
    labels: {
      app: "zoobernetes",
    },
  },
  rules: [
    {
      apiGroups: ["*"],
      resources: ["namespaces", "services", "serviceentries"],
      verbs: ["*"],
    },
  ],
}
