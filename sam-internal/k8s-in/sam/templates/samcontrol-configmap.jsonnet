local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samcontrol",
      namespace: "sam-system",
    },
    data: {
      "samcontrol.json": std.toString(import "configs/samcontrol-config.jsonnet"),
    },
}
