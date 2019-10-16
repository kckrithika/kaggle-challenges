local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local name = "crd-watcher";
 if configs.kingdom != "mvp" && (configs.estate == "prd-samtest" || configs.estate == "prd-samdev") then {
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
    } else "SKIP"
