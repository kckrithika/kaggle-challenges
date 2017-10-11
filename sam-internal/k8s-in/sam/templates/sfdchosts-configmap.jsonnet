local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfdchosts",
      namespace: "sam-system",
    },
    data: {
      "hosts.json": std.toString(import "configs/hosts_filtered.jsonnet"),
    },
}
