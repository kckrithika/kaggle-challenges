local configs = import "config.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "istio-mesh-webhook",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-mesh-webhook",
    },
  },
  rules: [
    {
      apiGroups: [
        "networking.istio.io",
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
