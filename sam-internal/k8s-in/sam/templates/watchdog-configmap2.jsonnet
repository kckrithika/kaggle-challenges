local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_aws(configs.kingdom) then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "watchdog",
        namespace: "sam-watchdog",  # This is a copy of the same configMap for the other sam-watchdog namespace
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "watchdog.json": std.toString(import "configs/watchdog-config.jsonnet"),
    },
} else "SKIP"
