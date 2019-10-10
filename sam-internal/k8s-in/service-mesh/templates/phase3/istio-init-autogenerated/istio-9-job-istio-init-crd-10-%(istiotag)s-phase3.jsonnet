# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "istio-init-crd-10-%(istioTag)s" % mcpIstioConfig,
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
              "/etc/istio/crd-10/crd-10.yaml",
            ],
            image: "%(istioHub)s/kubectl:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "IfNotPresent",
            name: "istio-init-crd-10",
            volumeMounts: [
              {
                mountPath: "/etc/istio/crd-10",
                name: "crd-10",
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
              name: "istio-crd-10",
            },
            name: "crd-10",
          },
        ],
      },
    },
  },
}

else "SKIP"
