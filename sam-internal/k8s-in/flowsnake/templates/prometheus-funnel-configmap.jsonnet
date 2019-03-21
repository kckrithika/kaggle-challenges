local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "prometheus-server-conf",
        labels: {
            name: "prometheus-server-conf",
        },
        namespace: "flowsnake",
    },
    data: {
        "prometheus.json": std.toString(import "configs/prometheus-funnel-config.jsonnet"),
    },
}
