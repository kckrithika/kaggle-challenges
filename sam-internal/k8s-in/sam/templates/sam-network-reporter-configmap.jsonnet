local configs = import "config.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "xrd" || configs.kingdom == "frf" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-network-reporter",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "sam-network-reporter.json": std.toString(import "configs/sam-network-reporter.jsonnet"),
    },
} else "SKIP"
