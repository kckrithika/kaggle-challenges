local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "manifest-watcher",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "manifestwatcher.json": std.toString(import "configs/manifest-watcher-config.jsonnet"),
    },
}
