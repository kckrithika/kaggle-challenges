{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "sherpa-injector",
    namespace: "service-mesh",
    labels: {
      app: "sherpa-injector",
    },
  },
  spec: {
    ports: [
      {
        name: "h1-tls-in-port",
        port: 17442,
        targetPort: 17442,
      },
    ],
    selector: {
      app: "sherpa-injector",
    },
    type: "NodePort",
  },
}
