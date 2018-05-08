local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "fleet-config",
        namespace: "flowsnake",
    },
    data: {
        name: flowsnakeconfig.fleet_name,
        registry: flowsnakeconfig.registry,
        strata_registry: flowsnakeconfig.strata_registry,
        kubeconfig: "/etc/kubernetes/kubeconfig",
    } +
    if std.objectHas(flowsnake_images.feature_flags, "watchdog_canaries") then
      {
        vip: flowsnakeconfig.fleet_vips[estate],
      }
    else
      {},
}
