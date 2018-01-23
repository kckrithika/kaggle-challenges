local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "sam-watchdog",  # This is a copy of the same configMap for the other sam-watchdog namespace
    },
    data: {
      "watchdog.json": std.toString(import "configs/watchdog-config.jsonnet"),
    },
}
