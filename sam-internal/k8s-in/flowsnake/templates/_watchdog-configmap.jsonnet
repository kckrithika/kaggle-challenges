local watchdog = import "watchdog.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
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
