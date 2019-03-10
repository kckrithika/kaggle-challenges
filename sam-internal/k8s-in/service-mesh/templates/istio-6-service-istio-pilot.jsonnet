# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    labels: {
      app: "istio-pilot",
      release: "istio",
    },
    name: "istio-pilot",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        name: "grpc-xds",
        port: 15010,
      },
      {
        name: "https-xds",
        port: 15011,
      },
      {
        name: "http-legacy-discovery",
        port: 8080,
      },
      {
        name: "http-monitoring",
        port: 9093,
      },
    ],
    selector: {
      istio: "pilot",
    },
  },
}
