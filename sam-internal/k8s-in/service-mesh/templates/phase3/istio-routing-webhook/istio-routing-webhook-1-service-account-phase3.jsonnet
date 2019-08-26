local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase3(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-routing-webhook-service-account",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-routing-webhook",
    },
  },
}
else "SKIP"
