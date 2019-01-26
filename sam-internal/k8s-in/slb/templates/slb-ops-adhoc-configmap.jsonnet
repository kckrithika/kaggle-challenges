local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate && slbflights.slbJournaldKillerEnabled then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-ops-adhoc",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-journald-killer.sh": std.toString(importstr "scripts/slb-journald-killer.sh"),
    },
} else
    "SKIP"
