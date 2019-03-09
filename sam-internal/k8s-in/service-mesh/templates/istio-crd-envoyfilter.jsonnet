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
    name: "envoyfilters.networking.istio.io",
  },
  spec: {
    group: "networking.istio.io",
    names: {
      categories: [
        "istio-io",
        "networking-istio-io",
      ],
      kind: "EnvoyFilter",
      plural: "envoyfilters",
      singular: "envoyfilter",
    },
    scope: "Namespaced",
    version: "v1alpha3",
  },
}
