# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRole",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "istio-init",
      istio: "init",
    },
    name: "istio-init-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "apiextensions.k8s.io",
      ],
      resources: [
        "customresourcedefinitions",
      ],
      verbs: [
        "create",
        "get",
        "list",
        "watch",
        "patch",
      ],
    },
  ],
}
else "SKIP"
