local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: {
      "slb.sfdc.net/name": "sam-manifest-repo-watcher",
    },
    labels: {
      app: "sam-manifest-repo-watcher",
    } + configs.ownerLabel.sam,
    name: "sam-manifest-repo-watcher",
    namespace: "sam-system",
  },
  spec: {
    ports: [
      {
        name: "sam-manifest-repo-watcher-port",
        port: 80,
        protocol: "TCP",
        targetPort: 8099,
        nodePort: 39865,
      },
    ],
    selector: {
      name: "sam-manifest-repo-watcher",
    },
    type: "NodePort",
  },
} else "SKIP"
