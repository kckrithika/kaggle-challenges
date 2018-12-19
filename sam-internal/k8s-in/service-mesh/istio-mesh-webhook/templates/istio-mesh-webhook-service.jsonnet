local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-mesh-webhook",
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
      app: "istio-mesh-webhook",
    },
  },
} else "SKIP"
