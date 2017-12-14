local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "sam-watchdog",
    },
    data: {
      "watchdog.json": std.toString(import "configs/watchdog-config.jsonnet"),
    },
}
