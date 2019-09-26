# Sidecar to apply casam sidecar defaults.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "casam-na7-sidecar",
    namespace: "core-on-sam-sp2",
  },
  spec: {
    egress: [
      {
        port: {
          number: 15008,
          protocol: "Redis",
          name: "redis-caas",
        },
        hosts: [
            "*/na7-mist61-caas-prd.service-mesh.svc.cluster.local",
        ],
        bind: "0.0.0.0",  # We could choose to bind this to 127.1.2.3 or wildcard, wildcard aligns with how HTTP works.
      },
      {
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
    ],
  },
}
else "SKIP"
