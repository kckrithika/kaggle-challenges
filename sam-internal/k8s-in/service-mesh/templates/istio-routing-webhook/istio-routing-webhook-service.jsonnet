local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        port: 443,
        targetPort: 10443,
        name: "https",
      },
    ],
    selector: {
      app: "istio-routing-webhook",
    },
  },
}
