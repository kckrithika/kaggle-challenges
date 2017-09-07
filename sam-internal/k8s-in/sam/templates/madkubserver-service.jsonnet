local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" then {
  kind: "Service",
  metadata: {
    labels: {
      service: "madkubserver",
    },
    name: "madkubserver",
    namespace: "sam-system"
  },
  spec: {
    ports: [
      {
        name: "madkubapitls",
        port: 32007,
        targetPort: 32007,
      }
    ],
    selector: {
      service: "madkubserver",
    }
  },
  status: {
    loadBalancer: {},
  }
} else "SKIP"