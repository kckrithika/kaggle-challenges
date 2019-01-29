{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'istio-ingressgateway',
    namespace: 'mesh-control-plane',
    labels: {
      chart: 'gateways-1.0.2',
      release: 'istio',
      app: 'istio-ingressgateway',
      istio: 'ingressgateway',
    },
  },
  spec: {
    type: 'LoadBalancer',
    selector: {
      app: 'istio-ingressgateway',
      istio: 'ingressgateway',
    },
    ports: [
      {
        name: 'http2',
        nodePort: 32380,
        port: 80,
        targetPort: 80,
      },
      {
        name: 'https',
        nodePort: 32390,
        port: 443,
      },
      {
        name: 'tcp',
        nodePort: 32400,
        port: 32400,
      },
      {
        name: 'tcp-pilot-grpc-tls',
        port: 15011,
        targetPort: 15011,
      },
      {
        name: 'tcp-citadel-grpc-tls',
        port: 8060,
        targetPort: 8060,
      },
      {
        name: 'tcp-dns-tls',
        port: 853,
        targetPort: 853,
      },
    ],
  },
}
