local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshotconsumer-prd",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshotconsumer-prd.json": std.toString(import "configs/snapshotconsumer-prd-config.jsonnet"),
    },
} else "SKIP"
