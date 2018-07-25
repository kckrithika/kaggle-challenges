local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-cleanup-unknownpods",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slb-cleanup-unknownpods.sh": std.toString(importstr "scripts/slb-cleanup-unknownpods.sh"),
    },
} else
    "SKIP"
