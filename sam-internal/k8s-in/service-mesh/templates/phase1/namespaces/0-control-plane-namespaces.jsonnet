local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        labels: {
          "istio-injection": "disabled",
          "sherpa-injection": "disabled",
        },
        name: "mesh-control-plane",
      },
    },
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        name: "mesh-control-plane-temp",
      },
    },
  ],
  kind: "List",
}
else "SKIP"
