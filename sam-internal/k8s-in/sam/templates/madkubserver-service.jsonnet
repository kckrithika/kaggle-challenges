local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    labels: {
      service: "madkubserver",
    },
    name: "madkubserver",
    namespace: "sam-system",
  },
  spec: {
    # Hardcoding the ClusterIp for now as we dont have DNS/SLB
    clusterIP: "10.254.208.254",
    ports: [
      {
        name: "madkubapitls",
        port: 32007,
        targetPort: 32007,
      },
    ],
    selector: {
      service: "madkubserver",
    },
  },
  status: {
    loadBalancer: {},
  },
} else "SKIP"
