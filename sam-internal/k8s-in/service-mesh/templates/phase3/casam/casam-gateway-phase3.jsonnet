local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if istioPhases.is_phase3(mcpIstioConfig.controlEstate) then
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Gateway",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "ingressgateway",
    namespace: "core-on-sam-sp2",
  },
  spec: {
    selector: {
      istio: "ingressgateway",
    },
    servers: [
      {
        hosts: [
          "*",
        ],
        port: {
          name: "https",
          number: 8085,
          protocol: "HTTPS",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/etc/certs/key.pem",
          serverCertificate: "/etc/certs/cert-chain.pem",
        },
      },
      {
        hosts: [
          "*",
        ],
        port: {
          name: "https",
          number: 8443,
          protocol: "HTTPS",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/etc/certs/key.pem",
          serverCertificate: "/etc/certs/cert-chain.pem",
        },
      },
      {
        hosts: [
          "*",
        ],
        port: {
          name: "tcp-secure",
          number: 2525,
          protocol: "TCP",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/etc/certs/key.pem",
          serverCertificate: "/etc/certs/cert-chain.pem",
        },
      },
    ],
  },
}
else "SKIP"
