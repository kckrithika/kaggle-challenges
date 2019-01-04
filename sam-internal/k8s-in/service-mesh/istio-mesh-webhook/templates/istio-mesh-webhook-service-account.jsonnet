local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-mesh-webhook-service-account",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-mesh-webhook",
    },
  },
}
