# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "istio-init-crd-all-aa56850ad9a1bc39fc8583dcd4eda1d6",
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
              "/etc/istio/crd-all/crd-all.gen.yaml",
            ],
            image: "%(istioHub)s/kubectl:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "Always",
            name: "istio-init-crd-all",
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
                mountPath: "/etc/istio/crd-all",
                name: "crd-all",
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
              name: "istio-crd-all",
            },
            name: "crd-all",
          },
        ],
      },
    },
  },
}

else "SKIP"
