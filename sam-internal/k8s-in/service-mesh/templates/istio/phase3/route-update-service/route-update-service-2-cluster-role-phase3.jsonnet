local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "route-update-service",
    namespace: "service-mesh",
    labels: {
      app: "route-update-service",
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
  ],
}
else "SKIP"
