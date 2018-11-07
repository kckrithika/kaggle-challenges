local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshot-consumer-prod-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshot-consumer-prod-mtls.json": std.toString(import "configs/snapshot-consumer-prod-mtls-config.jsonnet"),
    },
} else "SKIP"
