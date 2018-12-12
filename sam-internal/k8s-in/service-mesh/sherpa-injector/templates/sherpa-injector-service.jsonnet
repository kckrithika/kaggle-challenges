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
        name: "tls-in-port",
        port: 7443,
        targetPort: 7443,
      },
    ],
    selector: {
      app: "sherpa-injector",
    },
    type: "NodePort",
  },
}
