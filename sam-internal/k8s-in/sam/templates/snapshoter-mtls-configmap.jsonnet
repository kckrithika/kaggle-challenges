local configs = import "config.jsonnet";

if configs.kingdom == "prd" && configs.estate != "prd-samtwo" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "snapshoter-mtls",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "snapshoter-mtls.json": std.toString(import "configs/snapshoter-mtls-config.jsonnet"),
    },
} else "SKIP"
