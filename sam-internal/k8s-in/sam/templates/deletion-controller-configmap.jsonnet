local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "deletion-controller",
        namespace: "sam-clean-up",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "deleteConfig.json": std.toString(import "configs/deletion-controller-config.jsonnet"),
    },
} else "SKIP"
