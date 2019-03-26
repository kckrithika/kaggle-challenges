# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
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
