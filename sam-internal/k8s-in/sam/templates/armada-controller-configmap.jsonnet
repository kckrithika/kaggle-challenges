local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "armada-controller",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "armada-config.json": std.toString(import "configs/armada-config.jsonnet"),
    },
} else "SKIP"
