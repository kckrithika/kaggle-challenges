# Sidecar to apply mesh-wide defaults.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
      "niko/fake.change.for.redeploy": "3",
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
