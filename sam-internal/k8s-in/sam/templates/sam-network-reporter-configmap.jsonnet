local configs = import "config.jsonnet";

{
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
}
