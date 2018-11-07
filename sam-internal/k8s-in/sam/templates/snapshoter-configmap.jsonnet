local configs = import "config.jsonnet";

if configs.estate != "prd-sam" && configs.estate != "prd-samdev" && configs.kingdom != "cdu" && configs.kingdom != "frf" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshoter",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshoter.json": std.toString(import "configs/snapshoter-config.jsonnet"),
    },
} else "SKIP"
