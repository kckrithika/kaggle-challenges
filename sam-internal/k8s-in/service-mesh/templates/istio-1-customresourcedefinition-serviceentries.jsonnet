# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "apiextensions.k8s.io/v1beta1",
  kind: "CustomResourceDefinition",
  metadata: {
    annotations: {
      "helm.sh/hook": "crd-install",
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "istio-pilot",
    },
    name: "serviceentries.networking.istio.io",
  },
  spec: {
    group: "networking.istio.io",
    names: {
      categories: [
        "istio-io",
        "networking-istio-io",
      ],
      kind: "ServiceEntry",
      listKind: "ServiceEntryList",
      plural: "serviceentries",
      singular: "serviceentry",
    },
    scope: "Namespaced",
    version: "v1alpha3",
  },
}
