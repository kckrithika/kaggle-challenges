# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
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
      {
        name: "http-monitoring",
        port: 15014,
      },
    ],
    selector: {
      istio: "sidecar-injector",
    },
  },
}
else "SKIP"
