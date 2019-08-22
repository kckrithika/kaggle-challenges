local configs = import "config.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-routing-webhook",
    },
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-routing-webhook",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-routing-webhook-service-account",
      namespace: "mesh-control-plane",
    },
  ],
}
