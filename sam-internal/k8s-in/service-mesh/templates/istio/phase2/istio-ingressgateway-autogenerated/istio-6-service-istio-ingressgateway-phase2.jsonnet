# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: [
      "service.beta.kubernetes.io/aws-load-balancer-type",
    ],
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
