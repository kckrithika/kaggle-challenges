local configs = import "config.jsonnet";
## Preserve this old way of generating namespaces for everything but samdev & samtest
##
## TODO:NIKO: Remove the List version completely, when releasing to PAR
##
if (configs.kingdom != "prd") then
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
