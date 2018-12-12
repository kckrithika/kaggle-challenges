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
        port: 443,
        targetPort: 15010,
      },
    ],
    selector: {
      app: "sherpa-injector",
    },
  },
}
