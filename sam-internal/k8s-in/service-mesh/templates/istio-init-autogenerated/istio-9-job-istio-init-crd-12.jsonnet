# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: "istio-init-crd-12",
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
              "/etc/istio/crd-12/crd-12.yaml",
            ],
            image: mcpIstioConfig.kubectlImage,
            imagePullPolicy: "IfNotPresent",
            name: "istio-init-crd-12",
            volumeMounts: [
              {
                mountPath: "/etc/istio/crd-12",
                name: "crd-12",
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
              name: "istio-crd-12",
            },
            name: "crd-12",
          },
        ],
      },
    },
  },
}
