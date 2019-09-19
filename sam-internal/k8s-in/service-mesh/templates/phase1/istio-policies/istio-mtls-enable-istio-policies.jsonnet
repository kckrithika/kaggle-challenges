local mesh_namespaces = ["app", "service-mesh", "gater", "mesh-control-plane", "ccait", "funnel"];
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  items: [
    {
      apiVersion: "authentication.istio.io/v1alpha1",
      kind: "Policy",
      metadata: {
        annotations: {
          "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
        label: {
          test: "test",
        },
        name: "istio-mtls-enable",
        namespace: namespace,
      },
      spec: {
        peer_is_optional: true,  # SPIFFE URI check is skipped.
        peers: [
          {
            mtls: {},
          },
        ],
      },
    }
    for namespace in mesh_namespaces
  ],
  kind: "List",
  metadata: {},
}
else "SKIP"
