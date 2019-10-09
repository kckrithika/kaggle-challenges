# Sidecar to apply mesh-wide defaults.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
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
            name: "grpc-tls",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
      {
        port: {
            number: 7442,
            protocol: "HTTP",
            name: "http-tls",
        },
        hosts: mcpIstioConfig.sidecarEgressHosts,
      },
      {
        port: {
            number: 7014,
            protocol: "HTTP",
            name: "http-plain",
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
