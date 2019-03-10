# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    labels: {
      app: "istio-sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "*",
      ],
      resources: [
        "configmaps",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
    {
      apiGroups: [
        "admissionregistration.k8s.io",
      ],
      resources: [
        "mutatingwebhookconfigurations",
      ],
      verbs: [
        "get",
        "list",
        "watch",
        "patch",
      ],
    },
  ],
}
