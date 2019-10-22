local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local name = "crd-watcher";

# [karthik-sudana] We are migrating from crd-watcher to zrd-watcher because we want it to deploy after
# the watchdog services, as the autodeployer goes in alphabetical order.
 if configs.kingdom != "mvp" && configs.kingdom != "prd" && configs.estate != "xrd-sam" then {
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
