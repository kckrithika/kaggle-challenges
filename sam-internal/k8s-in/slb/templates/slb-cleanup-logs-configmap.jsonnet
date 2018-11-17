local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

local script =
    std.toString(importstr "scripts/slb-cleanup-log.sh");

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-cleanup-logs",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-cleanup-logs.sh": script,
    },
}
