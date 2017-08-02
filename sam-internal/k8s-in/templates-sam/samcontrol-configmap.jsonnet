local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samcontrol",
      namespace: "sam-system",
    },
    data: {
      "config.json": std.toString(import "../configs-sam/samcontrol-config.jsonnet")
    }
}