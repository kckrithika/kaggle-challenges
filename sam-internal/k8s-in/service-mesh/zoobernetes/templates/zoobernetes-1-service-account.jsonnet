{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "zoobernetessvcaccount",
    namespace: "discovery",
    labels: {
      app: "zoobernetes",
    },
  },
}
