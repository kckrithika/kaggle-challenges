{
  apiVersion: "v1",
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        labels: {
          "sherpa-injector.service-mesh/inject": "disabled",
          "istio-injection": "disabled",
        },
        name: "mesh-control-plane",
      },
    },
  ],
  kind: "List",
}
