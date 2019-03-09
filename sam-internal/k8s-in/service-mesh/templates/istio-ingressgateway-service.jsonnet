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
        name: "http2",
        nodePort: 31380,
        port: 80,
        targetPort: 80,
      },
      {
        name: "https",
        nodePort: 31390,
        port: 443,
      },
      {
        name: "tcp",
        nodePort: 31400,
        port: 31400,
      },
      {
        name: "tcp-pilot-grpc-tls",
        port: 15011,
        targetPort: 15011,
      },
      {
        name: "tcp-citadel-grpc-tls",
        port: 8060,
        targetPort: 8060,
      },
      {
        name: "tcp-dns-tls",
        port: 853,
        targetPort: 853,
      },
    ],
    selector: {
      app: "istio-ingressgateway",
      istio: "ingressgateway",
    },
    type: "LoadBalancer",
  },
}
