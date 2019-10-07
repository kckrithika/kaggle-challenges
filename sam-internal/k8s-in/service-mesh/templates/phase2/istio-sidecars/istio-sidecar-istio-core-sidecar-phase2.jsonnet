# Sidecar that applies to namespace `app` which is expected to be Core's ServiceEntry's namespace.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

local ingress(port, protocol, name, endpoint) =
{
  port: {
    number: port,  # Bind IP will be the host's actual IPV4 address.
    protocol: protocol,
    name: name,
  },
  captureMode: "NONE",
  defaultEndpoint: endpoint,
};

local egress(port, protocol, name) =
{
  bind: "127.1.2.3",
  port: {
    number: port,
    protocol: protocol,
    name: name,
  },
  captureMode: "NONE",
  hosts: mcpIstioConfig.sidecarEgressHosts,
};

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    name: "istio-core-sidecar",
    namespace: "app",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  spec: {
    ingress: [
      ingress(7443, "GRPC", "grpc-core", "127.0.0.1:7020"),
    ],
    egress: [
      egress(7443, "GRPC", "grpc-egress"),
//      egress(7012, "GRPC", "grpc-egress2"),
//      egress(7442, "HTTP", "http-egress"),
//      egress(7014, "HTTP", "http-egress2"),
    ],
  },
}
else "SKIP"
