local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog",
      namespace: "sam-system",
    },
    data: {
      "watchdog.json": std.toString(flowsnakeauthtopic.watchdog_config),
    },
}
