local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_test then ({
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshoter",
        namespace: "sam-system",
    },
    data: {
        "snapshoter.json": std.toString(import "configs/snapshoter-config.jsonnet"),
    },
}) else "SKIP"
