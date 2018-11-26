local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kafkaConsumer then {
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
