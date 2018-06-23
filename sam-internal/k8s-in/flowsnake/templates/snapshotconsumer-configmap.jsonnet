local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

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
