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
      app: "pilot",
      release: "istio",
    },
    name: "istio-pilot-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "config.istio.io",
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
        "rbac.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "get",
        "watch",
        "list",
      ],
    },
    {
      apiGroups: [
        "security.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "get",
        "watch",
        "list",
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
        "authentication.istio.io",
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
        "apiextensions.k8s.io",
      ],
      resources: [
        "customresourcedefinitions",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "extensions",
      ],
      resources: [
        "ingresses",
        "ingresses/status",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "",
      ],
      resources: [
        "configmaps",
      ],
      verbs: [
        "create",
        "get",
        "list",
        "watch",
        "update",
      ],
    },
    {
      apiGroups: [
        "",
      ],
      resources: [
        "endpoints",
        "pods",
        "services",
        "namespaces",
        "nodes",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
    {
      apiGroups: [
        "certificates.k8s.io",
      ],
      resources: [
        "certificatesigningrequests",
        "certificatesigningrequests/approval",
        "certificatesigningrequests/status",
      ],
      verbs: [
        "update",
        "create",
        "get",
        "delete",
      ],
    },
  ],
}
else "SKIP"
