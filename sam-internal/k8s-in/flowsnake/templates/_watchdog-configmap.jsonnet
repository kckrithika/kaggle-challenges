local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
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
