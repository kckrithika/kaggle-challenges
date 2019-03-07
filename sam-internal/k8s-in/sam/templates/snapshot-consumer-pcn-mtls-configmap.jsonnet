local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kafkaConsumer then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshot-consumer-pcn-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshot-consumer-pcn-mtls.json": std.toString(import "configs/snapshot-consumer-pcn-mtls-config.jsonnet"),
    },
} else "SKIP"
