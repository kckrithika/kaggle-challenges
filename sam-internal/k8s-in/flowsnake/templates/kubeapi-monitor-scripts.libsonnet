local flowsnake_images = import "flowsnake_images.jsonnet";
local configmap_data = {
    "check-kubeapi.sh": importstr "kubeapi-monitor-scripts/check-kubeapi.sh",
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
