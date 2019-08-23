# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase2(mcpIstioConfig.controlEstate) then
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRole",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "sidecarInjectorWebhook",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector-mesh-control-plane",
  },
  rules: [
    {
      apiGroups: [
        "",
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
else "SKIP"
