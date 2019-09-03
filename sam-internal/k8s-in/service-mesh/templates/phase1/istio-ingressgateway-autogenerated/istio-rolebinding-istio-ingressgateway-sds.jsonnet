# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "RoleBinding",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-ingressgateway-sds",
    namespace: "core-on-sam-sp2",
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
else "SKIP"
