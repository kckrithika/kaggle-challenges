local flowsnakeconfig = import "flowsnake_config.jsonnet";
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
        kubeconfig: "/etc/kubernetes/kubeconfig",
    },
}
