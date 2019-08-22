local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "route-update-service",
    namespace: "service-mesh",
  },
  spec: {
    ports: [
      {
        port: 7443,
        targetPort: 7443,
        name: "grpc",
      },
    ],
    selector: {
      app: "route-update-service",
    },
  },
}
