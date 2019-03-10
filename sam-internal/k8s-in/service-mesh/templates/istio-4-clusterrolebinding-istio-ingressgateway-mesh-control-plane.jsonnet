# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "istio-ingressgateway-mesh-control-plane",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-ingressgateway-mesh-control-plane",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-ingressgateway-service-account",
      namespace: "mesh-control-plane",
    },
  ],
}
