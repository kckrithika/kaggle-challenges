{
  apiVersion: "v1",
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        labels: {
          "istio-injection": "disabled",
          "sherpa-injector.service-mesh/inject": "disabled",
        },
        name: "mesh-control-plane",
      },
    },
  ],
  kind: "List",
}
