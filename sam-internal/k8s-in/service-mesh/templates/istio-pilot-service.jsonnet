local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

if configs.estate == "prd-samtest" then {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-pilot",
    namespace: "mesh-control-plane",
    labels: istioUtils.istioLabels,
  },
  spec: {
    ports: [
      {
        port: 15010,
        name: "grpc-xds",
      },
      {
        port: 15011,
        name: "https-xds",
      },
      {
        port: 8080,
        name: "http-legacy-discovery",
      },
      {
        port: 9093,
        name: "http-monitoring",
      },
    ],
    selector: {
      istio: "pilot",
    },
  },
}
else "SKIP"
