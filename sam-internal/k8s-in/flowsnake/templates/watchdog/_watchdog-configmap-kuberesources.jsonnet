local watchdog = import "watchdog.jsonnet";
if !watchdog.watchdog_enabled then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "watchdog-kuberesources",
      namespace: "flowsnake",
    },
    data: {
      # Override the kubeResourceNamespacePrefixWhitelist config:
      #   - kube-system for kube-state-metrics
      #   - flowsnake for prometheus
      "watchdog.json": std.toString(watchdog.watchdog_config + {
        kubeResourceNamespacePrefixWhitelist: "kube-system,flowsnake"
      }),
    },
}
