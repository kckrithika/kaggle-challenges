local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "frf" || utils.is_pcn(configs.kingdom) then
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "temp-crd-watcher",
            namespace: "sam-system",
            labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
        },
        data: {
            "tempmanifestwatcher.json": std.toString(import "configs/temp-crd-watcher-config.jsonnet"),
        },
    } else "SKIP"
