# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: {
      "slb.sfdc.net/name": "istio-ingressgateway",
      "slb.sfdc.net/portconfigurations": "[\n {\n  \"lbtype\": \"dsr\",\n  \"port\": 15008,\n  \"targetport\": 15008\n },\n {\n  \"lbtype\": \"dsr\",\n  \"port\": 15009,\n  \"targetport\": 15009\n },\n {\n  \"lbtype\": \"dsr\",\n  \"port\": 8085,\n  \"targetport\": 8085\n },\n {\n  \"lbtype\": \"dsr\",\n  \"port\": 8443,\n  \"targetport\": 8443\n }\n]",
    },
    labels: {
      app: "istio-ingressgateway",
      istio: "ingressgateway",
      release: "istio",
    },
    name: "istio-ingressgateway",
    namespace: "core-on-sam-sp2",
  },
  spec: {
    ports: [
      {
        name: "https-coreapp",
        port: 8443,
      },
      {
        name: "https-istio-coreapp",
        port: 8085,
      },
      {
        name: "tcp-coreapp",
        port: 2525,
      },
    ],
    selector: {
      app: "istio-ingressgateway",
      istio: "ingressgateway",
      release: "istio",
    },
    type: "LoadBalancer",
  },
}
else "SKIP"
