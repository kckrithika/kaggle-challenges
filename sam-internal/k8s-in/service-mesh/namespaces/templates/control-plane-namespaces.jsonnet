local configs = import "config.jsonnet";
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    labels: {
      "istio-injection": "disabled",
      "sherpa-injection": "disabled",
    },
    name: "mesh-control-plane",
  },
}
