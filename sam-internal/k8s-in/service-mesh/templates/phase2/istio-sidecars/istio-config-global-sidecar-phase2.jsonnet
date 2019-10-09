# Sidecar to apply mesh-wide defaults.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
      "niko/fake.change.for.redeploy": "3",
    },
    name: "mesh-default",
    namespace: "mesh-control-plane",
  },
  spec: {
    egress: [
      {
        port: {
            number: 7443,
            protocol: "GRPC",
            name: "http2-tls",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
      {
        port: {
            number: 7442,
            protocol: "HTTP",
            name: "http1-tls",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
      {
        port: {
            number: 7014,
            protocol: "HTTP",
            name: "http1-plain",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
      {
        port: {
            number: 7012,
            protocol: "GRPC",
            name: "grpc-plain",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
    ],
  },
}
else "SKIP"
