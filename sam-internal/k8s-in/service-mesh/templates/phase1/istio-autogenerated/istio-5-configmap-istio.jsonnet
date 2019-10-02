# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "v1",
  data: {
    mesh: "disablePolicyChecks: false\nenableTracing: true\naccessLogFile: \"/dev/stdout\"\naccessLogFormat: \"\"\naccessLogEncoding: 'TEXT'\ningressService: istio-ingressgateway\ndnsRefreshRate: 300s\nsdsUdsPath:\nenableSdsTokenMount: false\nsdsUseK8sSaJwt: false\ntrustDomain:\noutboundTrafficPolicy:\n  mode: ALLOW_ANY\nrootNamespace: mesh-control-plane\nproxyListenPort: 15002\nproxyHttpPort: 0\nconcurrency: 0\ninboundClusterStatName: \"local_service.%SERVICE_PORT%\"\noutboundClusterStatName: \"%SERVICE%.%SERVICE_PORT%\"\ndefaultConfig:\n  connectTimeout: 10s\n  configPath: \"/etc/istio/proxy\"\n  binaryPath: \"/usr/local/bin/envoy\"\n  serviceCluster: istio-proxy\n  drainDuration: 45s\n  parentShutdownDuration: 1m0s\n  interceptionMode: REDIRECT\n  proxyAdminPort: 15373\n  tracing:\n    zipkin:\n      address: zipkin.service-mesh:9411\n  envoyMetricsService:\n    address: switchboard.service-mesh:15001\n    tlsSettings:\n      caCertificates: /client-certs/ca.pem\n      clientCertificate: /client-certs/client/certificates/client.pem\n      mode: MUTUAL\n      privateKey: /client-certs/client/keys/client-key.pem\n      sni: null\n      subjectAltNames: []\n    tcpKeepalive:\n      interval: 10s\n      probes: 3\n      time: 10s\n  controlPlaneAuthPolicy: MUTUAL_TLS\n  discoveryAddress: istio-pilot.mesh-control-plane:15011",
    meshNetworks: "networks: {}",
  },
  kind: "ConfigMap",
  metadata: {
    labels: {
      app: "istio",
      release: "istio",
    },
    name: "istio",
    namespace: "mesh-control-plane",
  },
}
else "SKIP"
