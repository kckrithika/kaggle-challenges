# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "v1",
  data: {
    "crd-14.yaml": "kind: CustomResourceDefinition\napiVersion: apiextensions.k8s.io/v1beta1\nmetadata:\n  name: authorizationpolicies.security.istio.io\n  labels:\n    app: istio-pilot\n    istio: security\n    heritage: Tiller\n    release: istio\nspec:\n  group: security.istio.io\n  names:\n    kind: AuthorizationPolicy\n    plural: authorizationpolicies\n    singular: authorizationpolicy\n    categories:\n      - istio-io\n      - security-istio-io\n  scope: Namespaced\n  versions:\n    - name: v1beta1\n      served: true\n      storage: true\n---",
  },
  kind: "ConfigMap",
  metadata: {
    name: "istio-crd-14",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
