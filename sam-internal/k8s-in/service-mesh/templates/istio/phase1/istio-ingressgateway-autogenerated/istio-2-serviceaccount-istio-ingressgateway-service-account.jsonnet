# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "istio-ingressgateway",
      release: "istio",
    },
    name: "istio-ingressgateway-service-account",
    namespace: "core-on-sam-sp2",
  },
}
else "SKIP"
