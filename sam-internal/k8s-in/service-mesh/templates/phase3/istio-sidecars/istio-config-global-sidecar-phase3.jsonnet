# Sidecar to apply mesh-wide defaults.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase3(mcpIstioConfig.controlEstate) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "mesh-default",
    namespace: "mesh-control-plane",
  },
  spec: {
    egress: [
      {
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
    ],
  },
}
else "SKIP"
