local configs = import "config.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "frf" then
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "temp-crd-watcher",
            namespace: "sam-system",
            labels: {} + configs.ownerLabel.sam,
        },
        data: {
            "tempmanifestwatcher.json": std.toString(import "configs/temp-crd-watcher-config.jsonnet"),
        },
    } else "SKIP"
