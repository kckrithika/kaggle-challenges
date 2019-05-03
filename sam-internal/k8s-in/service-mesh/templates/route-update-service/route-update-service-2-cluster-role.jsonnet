local configs = import "config.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "route-update-service",
    namespace: "service-mesh",
    labels: {
      app: "route-update-service",
    },
  },
  rules: [
    {
      apiGroups: [
        "mesh.sfdc.net",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
  ],
}
