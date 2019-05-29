local watchdog = import "watchdog.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

if !watchdog.watchdog_enabled || !std.objectHas(flowsnake_images.feature_flags, "watchdog_kuberesources") || std.objectHas(flowsnake_images.feature_flags, "rm_kuberesources_cm") then
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
