local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_pcn(configs.kingdom) then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "node-labeler",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "node-labeler-config.json": std.toString(import "configs/node-labeler-config.jsonnet"),
    },
} else "SKIP"
