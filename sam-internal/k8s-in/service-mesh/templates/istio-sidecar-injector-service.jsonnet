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
