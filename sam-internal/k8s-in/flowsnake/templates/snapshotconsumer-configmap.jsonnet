local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

# TODO: testing currently in PRD data, uncomment when test topic permissions fixed
# if flowsnake_config.is_test then
if estate == "prd-data-flowsnake" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshotconsumer",
        namespace: "flowsnake",
    },
    data: {
        "snapshotconsumer.json": std.toString(import "configs/snapshotconsumer-config.jsonnet"),
    },
} else "SKIP"
