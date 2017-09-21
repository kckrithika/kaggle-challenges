local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "hosts",
      namespace: "sam-system",
    },
    data: {
      "hosts.json": std.toString(import "configs/hosts_filtered.jsonnet")
    }
}
