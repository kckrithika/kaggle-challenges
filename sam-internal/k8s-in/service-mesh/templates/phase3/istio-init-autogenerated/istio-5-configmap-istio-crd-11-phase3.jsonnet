# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "v1",
  data: {
    "crd-11.yaml": "apiVersion: apiextensions.k8s.io/v1beta1\nkind: CustomResourceDefinition\nmetadata:\n  name: sidecars.networking.istio.io\n  labels:\n    app: istio-pilot\n    chart: istio\n    heritage: Tiller\n    release: istio\n  annotations:\n    \"helm.sh/resource-policy\": keep\nspec:\n  group: networking.istio.io\n  names:\n    kind: Sidecar\n    plural: sidecars\n    singular: sidecar\n    categories:\n    - istio-io\n    - networking-istio-io\n  scope: Namespaced\n  versions:\n    - name: v1alpha3\n      served: true\n      storage: true\n---",
  },
  kind: "ConfigMap",
  metadata: {
    name: "istio-crd-11",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
