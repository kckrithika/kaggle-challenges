{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "sherpa-injector-svc",
    namespace: "service-mesh",
    labels: {
      app: "sherpa-injector",
    },
  },
  spec: {
    ports: [
      {
        name: "in-port",
        port: 15010,
        targetPort: 15010,
        nodePort: 33442,
      },
    ],
    selector: {
      app: "sherpa-injector",
    },
    type: "NodePort",
  },
}
