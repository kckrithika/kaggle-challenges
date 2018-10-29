local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshot-consumer-prd-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshot-consumer-prd-mtls.json": std.toString(import "configs/snapshot-consumer-prd-mtls-config.jsonnet"),
    },
} else "SKIP"
