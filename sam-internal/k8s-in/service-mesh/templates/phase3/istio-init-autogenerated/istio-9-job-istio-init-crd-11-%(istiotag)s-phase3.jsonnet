# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "istio-init-crd-11-%(istioTag)s" % mcpIstioConfig,
    namespace: "mesh-control-plane",
  },
  spec: {
    template: {
      metadata: {
        annotations: {
          "sidecar.istio.io/inject": "false",
        },
      },
      spec: {
        containers: [
          {
            command: [
              "kubectl",
              "apply",
              "-f",
              "/etc/istio/crd-11/crd-11.yaml",
            ],
            image: "%(istioHub)s/kubectl:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "IfNotPresent",
            name: "istio-init-crd-11",
            volumeMounts: [
              {
                mountPath: "/etc/istio/crd-11",
                name: "crd-11",
                readOnly: true,
              },
            ],
          },
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
        },
        restartPolicy: "OnFailure",
        serviceAccountName: "istio-init-service-account",
        volumes: [
          {
            configMap: {
              name: "istio-crd-11",
            },
            name: "crd-11",
          },
        ],
      },
    },
  },
}

else "SKIP"
