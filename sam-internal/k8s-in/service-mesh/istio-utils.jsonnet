{
  istioCrd(crd, annotations):: {
    apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: crd.plural + ".networking.istio.io",
      annotations: annotations {
        "helm.sh/hook": "crd-install",
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {
        app: "istio-pilot",
      },
    },
    spec: {
      group: "networking.istio.io",
      names: crd {
        categories: [
          "istio-io",
          "networking-istio-io",
        ],
      },
      scope: "Namespaced",
      version: "v1alpha3",
    },
  },

  istioLabels:: {
    app: "istio",
    chart: "istio-1.0.1",
    release: "istio",
    heritage: "Tiller",
  },

}
