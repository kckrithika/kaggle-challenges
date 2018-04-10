local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: {
      "slb.sfdc.net/name": "sam-api-proxy",
    },
    labels: {
      app: "sam-api-proxy",
    },
    name: "sam-api-proxy",
  },
  spec: {
    ports: [
      {
        name: "sam-api-proxy-port",
        port: 9190,
        protocol: "TCP",
        targetPort: 9190,
        nodePort: 39872,
      },
    ],
    selector: {
      name: "sam-api-proxy",
    },
    type: "NodePort",
  },
} else "SKIP"
