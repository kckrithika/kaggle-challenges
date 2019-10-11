local configs = import "config.jsonnet";
## Preserve this old way of generating namespaces for everything but samdev & samtest
if ((configs.estate != "prd-samdev") && (configs.estate != "prd-samtest")) then
{
  apiVersion: "v1",
  items: [
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
    },
  ],
  kind: "List",
}
else
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
