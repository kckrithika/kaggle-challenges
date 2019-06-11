# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
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
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/kubectl:f500cb1e6e3dfb7974af66ac91cb347098595916",
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
