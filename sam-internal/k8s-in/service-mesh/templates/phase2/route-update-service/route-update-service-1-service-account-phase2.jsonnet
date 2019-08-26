local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase2(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "route-update-service-service-account",
    namespace: "service-mesh",
    labels: {
      app: "route-update-service",
    },
  },
}
else "SKIP"
