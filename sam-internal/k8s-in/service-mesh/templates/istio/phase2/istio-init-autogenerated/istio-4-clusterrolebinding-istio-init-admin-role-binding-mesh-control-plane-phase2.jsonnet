# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRoleBinding",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "istio-init",
      istio: "init",
    },
    name: "istio-init-admin-role-binding-mesh-control-plane",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-init-mesh-control-plane",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-init-service-account",
      namespace: "mesh-control-plane",
    },
  ],
}
else "SKIP"