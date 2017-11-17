local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfdchosts",
      namespace: "flowsnake",
    },
    data: {
      "hosts.json": std.toString(import "flowsnake_hosts.jsonnet"),
    },
}
