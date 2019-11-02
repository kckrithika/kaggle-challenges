# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  data: {
    "crd-mixer.yaml": "kind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: adapters.config.istio.io\n  labels:\n    app: mixer\n    package: adapter\n    istio: mixer-adapter\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: adapter\n    plural: adapters\n    singular: adapter\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  subresources:\n    status: {}\n  version: \"v1alpha2\"\n  versions:\n    - name: v1alpha2\n      served: true\n      storage: true\n---\nkind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: instances.config.istio.io\n  labels:\n    app: mixer\n    package: instance\n    istio: mixer-instance\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: instance\n    plural: instances\n    singular: instance\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  subresources:\n    status: {}\n  version: \"v1alpha2\"\n  versions:\n    - name: v1alpha2\n      served: true\n      storage: true\n---\nkind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: templates.config.istio.io\n  labels:\n    app: mixer\n    package: template\n    istio: mixer-template\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: template\n    plural: templates\n    singular: template\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  subresources:\n    status: {}\n  version: \"v1alpha2\"\n  versions:\n    - name: v1alpha2\n      served: true\n      storage: true\n---\nkind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: handlers.config.istio.io\n  labels:\n    app: mixer\n    package: handler\n    istio: mixer-handler\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: config.istio.io\n  names:\n    kind: handler\n    plural: handlers\n    singular: handler\n    categories:\n    - istio-io\n    - policy-istio-io\n  scope: Namespaced\n  subresources:\n    status: {}\n  version: \"v1alpha2\"\n  versions:\n    - name: v1alpha2\n      served: true\n      storage: true\n---",
  },
  kind: "ConfigMap",
  metadata: {
    name: "istio-crd-mixer",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
