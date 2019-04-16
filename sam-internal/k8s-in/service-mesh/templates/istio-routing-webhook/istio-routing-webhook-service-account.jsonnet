local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-routing-webhook",
    },
  },
}
