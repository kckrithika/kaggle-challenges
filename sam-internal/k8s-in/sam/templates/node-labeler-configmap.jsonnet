local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "node-labeler",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "node-labeler-config.json": std.toString(import "configs/node-labeler-config.jsonnet"),
    },
} else "SKIP"
