# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase1(mcpIstioConfig.controlEstate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    labels: {
      app: "sidecarInjectorWebhook",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        name: "sidecar-injector-port",
        port: 443,
        targetPort: 15009,
      },
    ],
    selector: {
      istio: "sidecar-injector",
    },
  },
}
else "SKIP"
