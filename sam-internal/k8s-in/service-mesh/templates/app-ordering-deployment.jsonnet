local configs = import "config.jsonnet";
local istioImages = (import "istio-images.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
configs.deploymentBase("service-mesh") {
  metadata: {
    creationTimestamp: null,
    name: "ordering-istio",
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
          app: "ordering-istio",
          version: "v1",
        },
      },
      spec: {
        nodeSelector: {
          master: "true",
        },
        containers: [
          {
            env: [
              {
                name: "SCONE_SHIPPING_DEST",
                value: "shipping-istio.service-mesh:7020",
              },
            ],
            image: istioImages.ordering,
            imagePullPolicy: "IfNotPresent",
            name: "ordering",
            ports: [
              {
                containerPort: 7021,
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
