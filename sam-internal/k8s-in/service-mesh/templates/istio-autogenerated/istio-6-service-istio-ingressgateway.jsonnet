# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: null,
    labels: {
      app: "istio-ingressgateway",
      istio: "ingressgateway",
      release: "istio",
    },
    name: "istio-ingressgateway",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        name: "tcp",
        nodePort: 32400,
        port: 32400,
      },
      {
        name: "http2",
        nodePort: 32380,
        port: 80,
        targetPort: 80,
      },
      {
        name: "https",
        nodePort: 32390,
        port: 443,
      },
      {
        name: "https-kiali",
        port: 15029,
        targetPort: 15029,
      },
      {
        name: "https-tracing",
        port: 15032,
        targetPort: 15032,
      },
      {
        name: "tls",
        port: 15443,
        targetPort: 15443,
      },
      {
        name: "status-port",
        port: 15020,
        targetPort: 15020,
      },
    ],
    selector: {
      app: "istio-ingressgateway",
      istio: "ingressgateway",
      release: "istio",
    },
    type: "LoadBalancer",
  },
}
