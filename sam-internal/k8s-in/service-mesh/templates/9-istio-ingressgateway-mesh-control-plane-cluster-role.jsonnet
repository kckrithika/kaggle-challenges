# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    labels: {
      app: "gateways",
      release: "istio",
    },
    name: "istio-ingressgateway-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "extensions",
      ],
      resources: [
        "thirdpartyresources",
        "virtualservices",
        "destinationrules",
        "gateways",
      ],
      verbs: [
        "get",
        "watch",
        "list",
        "update",
      ],
    },
  ],
}
