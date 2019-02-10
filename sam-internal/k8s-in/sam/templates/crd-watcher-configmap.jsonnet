local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "temp-crd-watcher",
            namespace: "sam-system",
            labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
        },
        data: {
            "tempmanifestwatcher.json": std.toString(import "configs/crd-watcher-config.jsonnet"),
        },
    }
