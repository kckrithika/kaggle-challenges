local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";

if samfeatureflags.kafkaProducer then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshoter-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "snapshoter-mtls.json": "" + (if utils.is_pcn(configs.kingdom) then std.toString(import "configs/snapshoter-pcn-config.jsonnet") else std.toString(import "configs/snapshoter-mtls-config.jsonnet")),
    },
} else "SKIP"
