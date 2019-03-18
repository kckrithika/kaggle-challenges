local flowsnakeconfig = import "flowsnake_config.jsonnet";
# This is identical to _fleet-config.jsonnet, but in the default namespace. Currently we have two because component node-monitor-rc.jsonnet expects this data in this namespace.
if flowsnakeconfig.is_v1_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "fleet-config",
        namespace: "default",
    },
    data: {
        name: flowsnakeconfig.fleet_name,
        registry: flowsnakeconfig.registry,
        strata_registry: flowsnakeconfig.strata_registry,
        kubeconfig: "/etc/kubernetes/kubeconfig",
    },
} else "SKIP"
