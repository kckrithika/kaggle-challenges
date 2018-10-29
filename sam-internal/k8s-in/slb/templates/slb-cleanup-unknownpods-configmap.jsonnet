local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

local script = (
if slbflights.slbCleanupTerminatingPods then
    std.toString(importstr "scripts/slb-cleanup-stuckpods.sh")
else
    std.toString(importstr "scripts/slb-cleanup-unknownpods-old.sh")
);

if slbconfigs.isSlbEstate then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-cleanup-unknownpods",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-cleanup-unknownpods.sh": script,
    },
} else
    "SKIP"
