# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-init-crd-10",
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
            image: mcpIstioConfig.kubectlImage,
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
