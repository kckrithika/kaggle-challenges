local configs = import "config.jsonnet";
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
configs.deploymentBase("mesh-control-plane") {
  metadata+: {
    name: "proxy-init",
    namespace: "mesh-control-plane",
  },
  spec+: {
    replicas: 0,
    template: {
      metadata: {
        annotations+: {
          "sidecar.istio.io/inject": "false",
        },
        labels+: {
          name: "proxy-init",
        },
      },
      spec: {
        containers: [
          {
            name: "proxy-init",
            image: mcpIstioConfig.proxyInitImage,
            imagePullPolicy: "IfNotPresent",
            resources: {
              requests: {
                cpu: "10m",
                memory: "64Mi",
              },
              limits: {
                cpu: "10m",
                memory: "64Mi",
              },
            },
          },
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
        },
      },
    },
  },
}
else "SKIP"
