# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase2(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  data: {
    "crd-12.yaml": "kind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: authorizationpolicies.rbac.istio.io\n  labels:\n    app: istio-pilot\n    istio: rbac\n    heritage: Tiller\n    release: istio\nspec:\n  group: rbac.istio.io\n  names:\n    kind: AuthorizationPolicy\n    plural: authorizationpolicies\n    singular: authorizationpolicy\n    categories:\n      - istio-io\n      - rbac-istio-io\n  scope: Namespaced\n  version: v1alpha1\n---",
  },
  kind: "ConfigMap",
  metadata: {
    name: "istio-crd-12",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
