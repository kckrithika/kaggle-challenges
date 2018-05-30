local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_test then {
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
