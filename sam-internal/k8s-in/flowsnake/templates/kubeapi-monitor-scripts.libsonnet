local flowsnake_images = import "flowsnake_images.jsonnet";
local configmap_data = {
    "check-kubeapi.sh": if std.objectHas(flowsnake_images.feature_flags, "kubeapi_monitor_revise")
        then importstr "kubeapi-monitor-scripts/check-kubeapi-next.sh"
        else importstr "kubeapi-monitor-scripts/check-kubeapi.sh",
};

[
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "kubeapi-monitor-scripts",
            namespace: "flowsnake",
        },
        data: configmap_data,
    },
]
