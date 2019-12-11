# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "Role",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-ingressgateway-sds",
    namespace: "core-on-sam-sp2",
  },
  rules: [
    {
      apiGroups: [
        "",
      ],
      resources: [
        "secrets",
      ],
      verbs: [
        "get",
        "watch",
        "list",
      ],
    },
  ],
}
else "SKIP"