local configs = import "config.jsonnet";
local istioImages = (import "istio-images.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
configs.deploymentBase("service-mesh") {
  metadata: {
    creationTimestamp: null,
    name: "shipping-istio",
    namespace: "mesh-control-plane",
  },
  spec+: {
    replicas: 1,
    strategy: {
    },
    template: {
      metadata: {
        annotations: {
          "sidecar.istio.io/inject": "true",
        },
        labels: {
          app: "shipping-istio",
          version: "v1",
        },
      },
      spec: {
        nodeSelector: {
          master: "true",
        },
        containers: [
          {
            image: istioImages.shipping,
            imagePullPolicy: "IfNotPresent",
            name: "shipping",
            ports: [
              {
                containerPort: 7020,
              },
            ],
          },
        ],
      },
    },
  },
  status: {
  },
} else "SKIP"
