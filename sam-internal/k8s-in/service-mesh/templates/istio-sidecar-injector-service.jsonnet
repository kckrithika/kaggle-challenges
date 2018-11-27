{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-sidecar-injector",
    namespace: "service-mesh",
    labels: {
      istio: "sidecar-injector",
    },
  },
  spec: {
    ports: [
      {
        port: 443,
      },
    ],
    selector: {
      istio: "sidecar-injector",
    },
  },
}
