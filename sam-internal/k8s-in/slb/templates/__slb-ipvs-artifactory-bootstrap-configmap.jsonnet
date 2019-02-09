local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

if slbconfigs.isSlbEstate then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-ipvs-artifactory-bootstrap",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-hosts-updater.sh": std.toString(importstr "scripts/slb-hosts-updater.sh"),
    },
} else
    "SKIP"
