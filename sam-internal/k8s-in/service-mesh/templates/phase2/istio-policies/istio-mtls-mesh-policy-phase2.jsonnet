local mesh_namespaces = ["app", "service-mesh", "gater", "mesh-control-plane", "ccait", "funnel"];
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "authentication.istio.io/v1alpha1",
  kind: "MeshPolicy",
  metadata: {
    name: "default",
  },
  spec: {
    peers: [
      {
        mtls: {},
      },
    ],
  },
}
else "SKIP"
