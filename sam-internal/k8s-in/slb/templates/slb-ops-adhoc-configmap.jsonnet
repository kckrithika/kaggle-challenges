local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

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
    } + if slbflights.slbJournaldKillerScopeToJournaldHash then {
        "slb-journald-killer-journald-hash.sh": std.toString(importstr "scripts/slb-journald-killer-journald-hash.sh"),
    } else {},
} else
    "SKIP"
