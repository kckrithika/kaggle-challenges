# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    labels: {
      istio: "sidecar-injector",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        name: "sidecar-injector-port",
        port: 443,
        targetPort: 15009,
      },
    ],
    selector: {
      istio: "sidecar-injector",
    },
  },
}
