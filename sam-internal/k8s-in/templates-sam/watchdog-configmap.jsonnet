local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "sam-system",
    },
    data: {
      "config.json": std.toString(import "../configs-sam/watchdog-config.jsonnet")
    }
}