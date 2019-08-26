local mesh_namespaces = ["core-on-sam-sp2", "core-on-sam"];
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase1(mcpIstioConfig.controlEstate) then
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
}
else "SKIP"
