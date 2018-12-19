local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "istio-mesh-webhook",
    labels: {
      app: "istio-mesh-webhook",
    },
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-mesh-webhook",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-mesh-webhook-service-account",
      namespace: "mesh-control-plane",
    },
  ],
} else "SKIP"
