local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";

if false then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-ops-adhoc",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-cleanup-logs.sh": std.toString(importstr "scripts/slb-cleanup-logs.sh"),
    },
} else
    "SKIP"
