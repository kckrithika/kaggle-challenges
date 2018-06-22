local configs = import "config.jsonnet";

{
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
}
