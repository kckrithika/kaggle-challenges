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
