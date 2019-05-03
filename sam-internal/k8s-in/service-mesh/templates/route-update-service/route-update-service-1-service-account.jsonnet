local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "route-update-service-service-account",
    namespace: "service-mesh",
    labels: {
      app: "route-update-service",
    },
  },
}
