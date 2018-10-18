local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "shipping",
    namespace: "service-mesh",
  },
  spec: {
    ports: [
      {
        port: 7020,
        name: "grpc-service",
      },
    ],
    selector: {
      app: "shipping",
    },
  },
} else "SKIP"
