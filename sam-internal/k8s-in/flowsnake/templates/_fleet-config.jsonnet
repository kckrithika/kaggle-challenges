local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if flowsnakeconfig.is_v1_enabled then
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
        vip: flowsnakeconfig.fleet_vips[estate],
      },
} else "SKIP"
