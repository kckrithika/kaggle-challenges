local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-cleanup-unknownpods",
        namespace: "sam-system",
    },
    data: {
        "slb-cleanup-unknownpods.sh": std.toString(importstr "scripts/slb-cleanup-unknownpods.sh"),
    },
} else
    "SKIP"
