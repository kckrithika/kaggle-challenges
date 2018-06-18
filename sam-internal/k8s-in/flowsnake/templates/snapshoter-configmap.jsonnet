local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

# TODO: testing currently in PRD data, uncomment when test topic permissions fixed
# if flowsnake_config.is_test then
if estate == "prd-data-flowsnake" then ({
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshoter",
        namespace: "flowsnake",
    },
    data: {
        "snapshoter.json": std.toString(import "configs/snapshoter-config.jsonnet"),
    },
}) else "SKIP"
