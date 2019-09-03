local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "apiextensions.k8s.io/v1beta1",
  kind: "CustomResourceDefinition",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "route-update-service",
    },
    name: "routingcontexts.mesh.sfdc.net",
  },
  spec: {
    group: "mesh.sfdc.net",
    names: {
      categories: [
        "mesh-control-plane",
        "istio",
        "casam",
      ],
      kind: "RoutingContext",
      listKind: "RoutingContextList",
      plural: "routingcontexts",
      singular: "routingcontext",
    },
    scope: "Namespaced",
    version: "v1",
  },
}
else "SKIP"
