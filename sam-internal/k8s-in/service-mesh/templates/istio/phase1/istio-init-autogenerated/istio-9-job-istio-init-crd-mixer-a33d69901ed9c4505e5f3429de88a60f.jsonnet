# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "istio-init-crd-mixer-a33d69901ed9c4505e5f3429de88a60f",
    namespace: "mesh-control-plane",
  },
  spec: {
    template: {
      metadata: {
        annotations: {
          "sidecar.istio.io/inject": "false",
        },
        labels: null,
      },
      spec: {
        automountServiceAccountToken: true,
        containers: [
          {
            command: [
              "kubectl",
              "apply",
              "-f",
              "/etc/istio/crd-mixer/crd-mixer.yaml",
            ],
            image: "%(istioHub)s/kubectl:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "Always",
            name: "istio-init-crd-mixer",
            resources: {
              limits: {
                cpu: "100m",
                memory: "200Mi",
              },
              requests: {
                cpu: "10m",
                memory: "50Mi",
              },
            },
            volumeMounts: [
              {
                mountPath: "/etc/istio/crd-mixer",
                name: "crd-mixer",
                readOnly: true,
              },
            ],
          },
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
        },
        restartPolicy: "OnFailure",
        securityContext: {
          fsGroup: 7447,
          runAsNonRoot: true,
          runAsUser: 7447,
        },
        serviceAccountName: "istio-init-service-account",
        volumes: [
          {
            configMap: {
              name: "istio-crd-mixer",
            },
            name: "crd-mixer",
          },
        ],
      },
    },
  },
}

else "SKIP"