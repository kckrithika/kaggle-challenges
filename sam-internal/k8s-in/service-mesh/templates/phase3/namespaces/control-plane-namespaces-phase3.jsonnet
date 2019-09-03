local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    labels: {
      "istio-injection": "disabled",
      "sherpa-injector.service-mesh/inject": "disabled",
    },
    name: "mesh-control-plane",
  },
}
else "SKIP"
