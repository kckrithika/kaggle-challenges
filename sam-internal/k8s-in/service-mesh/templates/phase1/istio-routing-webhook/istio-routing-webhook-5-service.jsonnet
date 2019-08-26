local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase1(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        port: 443,
        targetPort: 10443,
        name: "https",
      },
    ],
    selector: {
      app: "istio-routing-webhook",
    },
  },
}
else "SKIP"
