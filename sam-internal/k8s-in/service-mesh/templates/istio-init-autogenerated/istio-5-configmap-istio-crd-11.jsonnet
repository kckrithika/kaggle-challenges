# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  data: {
    "crd-11.yaml": "kind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: cloudwatches.config.istio.io\n  labels:\n    app: mixer\n    package: cloudwatch\n    istio: mixer-adapter\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: cloudwatch\n    plural: cloudwatches\n    singular: cloudwatch\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  version: v1alpha2\n---\nkind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: dogstatsds.config.istio.io\n  labels:\n    app: mixer\n    package: dogstatsd\n    istio: mixer-adapter\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: dogstatsd\n    plural: dogstatsds\n    singular: dogstatsd\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  version: v1alpha2\n---\napiVersion: apiextensions.k8s.io/v1beta1\nkind: CustomResourceDefinition\nmetadata:\n  name: sidecars.networking.istio.io\n  labels:\n    app: istio-pilot\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: networking.istio.io\n  names:\n    kind: Sidecar\n    plural: sidecars\n    singular: sidecar\n    categories:\n    - istio-io\n    - networking-istio-io\n  scope: Namespaced\n  version: v1alpha3\n---\nkind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: zipkins.config.istio.io\n  labels:\n    app: mixer\n    package: zipkin\n    istio: mixer-adapter\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: zipkin\n    plural: zipkins\n    singular: zipkin\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  version: v1alpha2\n---",
  },
  kind: "ConfigMap",
  metadata: {
    name: "istio-crd-11",
    namespace: "mesh-control-plane",
  },
}
