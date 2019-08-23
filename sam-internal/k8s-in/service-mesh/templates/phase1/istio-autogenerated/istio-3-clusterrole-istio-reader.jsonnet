# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase1(mcpIstioConfig.controlEstate) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRole",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-reader",
  },
  rules: [
    {
      apiGroups: [
        "",
      ],
      resources: [
        "nodes",
        "pods",
        "services",
        "endpoints",
        "replicationcontrollers",
      ],
      verbs: [
        "get",
        "watch",
        "list",
      ],
    },
    {
      apiGroups: [
        "extensions",
        "apps",
      ],
      resources: [
        "replicasets",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
  ],
}
else "SKIP"
