local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
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
          name: "https-8085",
          number: 8085,
          protocol: "HTTPS",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/server-certs/server/keys/server-key.pem",
          serverCertificate: "/server-certs/server/certificates/server.pem",
          caCertificates: "/server-certs/ca.pem",
        },
      },
      {
        hosts: [
          "*",
        ],
        port: {
          name: "https-8443",
          number: 8443,
          protocol: "HTTPS",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/server-certs/server/keys/server-key.pem",
          serverCertificate: "/server-certs/server/certificates/server.pem",
          caCertificates: "/server-certs/ca.pem",
        },
      },
      {
        hosts: [
          "*",
        ],
        port: {
          name: "tcp-secure-2525",
          number: 2525,
          protocol: "TCP",
        },
        tls: {
          mode: "SIMPLE",
          privateKey: "/server-certs/server/keys/server-key.pem",
          serverCertificate: "/server-certs/server/certificates/server.pem",
          caCertificates: "/server-certs/ca.pem",
        },
      },
    ],
  },
}
else "SKIP"
