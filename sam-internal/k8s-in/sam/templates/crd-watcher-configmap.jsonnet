local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local name = (if configs.kingdom == "prd" then "crd-watcher" else "temp-crd-watcher");
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: name,
            namespace: "sam-system",
            labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
        },
        data: {
            "tempmanifestwatcher.json": std.toString(import "configs/crd-watcher-config.jsonnet"),
        },
    }
