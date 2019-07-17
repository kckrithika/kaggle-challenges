local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "switchboard-service-account",
    namespace: "core-on-sam-sp2",
    labels: {
      app: "switchboard",
    },
  },
}
