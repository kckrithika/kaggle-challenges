# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  data: {
    mesh: "disablePolicyChecks: false\nenableTracing: true\naccessLogFile: \"/dev/stdout\"\nsdsUdsPath: \"\"\nsdsRefreshDelay: 15s\ndefaultConfig:\n  connectTimeout: 10s\n  configPath: \"/etc/istio/proxy\"\n  binaryPath: \"/usr/local/bin/envoy\"\n  serviceCluster: istio-proxy\n  drainDuration: 45s\n  parentShutdownDuration: 1m0s\n  interceptionMode: REDIRECT\n  proxyAdminPort: 15000\n  concurrency: 0\n  zipkinAddress: zipkin.service-mesh:9411\n  controlPlaneAuthPolicy: NONE\n  discoveryAddress: istio-pilot.mesh-control-plane:15010",
  },
  kind: "ConfigMap",
  metadata: {
    labels: {
      app: "istio",
      chart: "istio-1.0.1",
      heritage: "Tiller",
      release: "istio",
    },
    name: "istio",
    namespace: "mesh-control-plane",
  },
}
