local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
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
