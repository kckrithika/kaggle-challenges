local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

if !std.objectHas(flowsnake_images.feature_flags, "spark_op_metrics") then
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
