local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "fleet-config",
        namespace: "flowsnake",
    },
    data: if flowsnakeconfig.is_098_registry_config then {
            name: flowsnakeconfig.fleet_name,
            registry: flowsnakeconfig.registry,
            strata_registry: flowsnakeconfig.strata_registry,
            kubeconfig: "/etc/kubernetes/kubeconfig",
        } else  // TODO: remove after all fleets on 0.9.8+
        {
            name: flowsnakeconfig.fleet_name,
            registry: flowsnakeconfig.registry,
            kubeconfig: "/etc/kubernetes/kubeconfig",
        },
}
