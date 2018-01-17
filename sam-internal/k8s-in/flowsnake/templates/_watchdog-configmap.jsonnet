local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
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
      "watchdog.json": std.toString(flowsnakeauthtopic.watchdog_config),
    },
}
