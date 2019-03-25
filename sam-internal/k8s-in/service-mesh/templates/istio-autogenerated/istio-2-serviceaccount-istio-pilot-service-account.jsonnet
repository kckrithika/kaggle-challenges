# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "pilot",
      release: "istio",
    },
    name: "istio-pilot-service-account",
    namespace: "mesh-control-plane",
  },
}
