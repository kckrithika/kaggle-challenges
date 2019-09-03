# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "sidecarInjectorWebhook",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector-service-account",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
