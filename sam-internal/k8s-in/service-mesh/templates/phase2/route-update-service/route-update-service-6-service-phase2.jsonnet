local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase2(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "route-update-service",
    namespace: "service-mesh",
  },
  spec: {
    ports: [
      {
        port: 7443,
        targetPort: 7443,
        name: "grpc",
      },
    ],
    selector: {
      app: "route-update-service",
    },
  },
}
else "SKIP"
