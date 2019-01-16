local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samapp-controller",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "samapp-controller-config.json": std.toString(import "configs/samapp-controller-config.jsonnet"),
    },
}
