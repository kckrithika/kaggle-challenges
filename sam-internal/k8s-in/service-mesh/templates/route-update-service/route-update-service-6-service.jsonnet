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
        port: 7020,
        targetPort: 7020,
        name: "grpc",
      },
    ],
    selector: {
      app: "route-update-service",
    },
  },
}
