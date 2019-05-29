local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.kingdom != "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "bundle-controller",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "bundle-controller-config.json": std.toString(import "configs/bundle-controller-config.jsonnet"),
    },
} else "SKIP"
