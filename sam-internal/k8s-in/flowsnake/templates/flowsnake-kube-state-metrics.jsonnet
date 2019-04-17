if std.objectHas(flowsnake_images.feature_flags, "kube_state_metrics_release") then
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: []
} else {}
