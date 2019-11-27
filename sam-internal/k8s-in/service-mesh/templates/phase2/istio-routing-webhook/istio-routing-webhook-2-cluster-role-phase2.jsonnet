local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio-routing-webhook",
    },
  },
  rules: [
    {
      apiGroups: [
        "mesh.sfdc.net",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "networking.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "extensions",  // for older deployments
        "apps",
      ],
      resources: [
        "deployments",
      ],
      verbs: [
       "get",
       "list",
      ],
    },
    {
      apiGroups: [
        "core",
      ],
      resources: [
        "namespaces",
      ],
      verbs: [
       "get",
       "list",
      ],
    },
  ],
}
else "SKIP"
