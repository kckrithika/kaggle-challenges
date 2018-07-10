local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshotconsumer",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshotconsumer-prod.json": std.toString(import "configs/snapshotconsumer-prod-config.jsonnet"),
    },
} else "SKIP"
