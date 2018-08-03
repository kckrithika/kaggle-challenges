local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "vpod" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "bundle-controller",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "bundle-controller-config.json": std.toString(import "configs/bundle-controller-config.jsonnet"),
    },
} else "SKIP"
