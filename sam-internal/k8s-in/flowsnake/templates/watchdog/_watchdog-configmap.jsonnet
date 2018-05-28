local watchdog = import "watchdog.jsonnet";
if !watchdog.watchdog_enabled then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "flowsnake",
    },
    data: {
      "watchdog.json": std.toString(watchdog.watchdog_config),
    },
}
