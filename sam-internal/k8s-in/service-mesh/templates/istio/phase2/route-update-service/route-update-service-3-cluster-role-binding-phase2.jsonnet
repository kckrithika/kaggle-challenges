local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "route-update-service",
    namespace: "service-mesh",
    labels: {
      app: "route-update-service",
    },
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "route-update-service",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "route-update-service-service-account",
      namespace: "service-mesh",
    },
  ],
}
else "SKIP"
