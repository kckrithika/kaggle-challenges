# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: {
      "slb.sfdc.net/name": "istio-pilot",
      "slb.sfdc.net/portconfigurations": "[\n {\n  \"lbtype\": \"dsr\",\n  \"port\": 15010,\n  \"targetport\": 15010\n }\n]",
    },
    labels: {
      app: "pilot",
      istio: "pilot",
      release: "istio",
    },
    name: "istio-pilot",
    namespace: "mesh-control-plane",
  },
  spec: {
    ports: [
      {
        name: "grpc-xds",
        port: 15010,
      },
      {
        name: "https-xds",
        port: 15011,
      },
      {
        name: "http-legacy-discovery",
        port: 8080,
      },
      {
        name: "http-monitoring",
        port: 15014,
      },
    ],
    selector: {
      istio: "pilot",
    },
  },
}
else "SKIP"
