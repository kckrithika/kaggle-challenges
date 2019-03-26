# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRole",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "ingressgateway",
      release: "istio",
    },
    name: "istio-ingressgateway-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "networking.istio.io",
      ],
      resources: [
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
