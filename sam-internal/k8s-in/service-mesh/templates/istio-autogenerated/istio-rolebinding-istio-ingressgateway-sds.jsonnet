# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "RoleBinding",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-ingressgateway-sds",
    namespace: "mesh-control-plane",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "Role",
    name: "istio-ingressgateway-sds",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-ingressgateway-service-account",
    },
  ],
}
