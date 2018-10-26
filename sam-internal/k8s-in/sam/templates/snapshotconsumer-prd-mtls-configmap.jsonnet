local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshotconsumer-prd-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshotconsumer-prd-mtls.json": std.toString(import "configs/snapshotconsumer-prd-mtls-config.jsonnet"),
    },
} else "SKIP"
