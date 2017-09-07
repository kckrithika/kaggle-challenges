local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "manifest-watcher",
      namespace: "sam-system",
    },
    data: {
      "manifestwatcher.json": std.toString(import "configs/manifest-watcher-config.jsonnet")
    }
}