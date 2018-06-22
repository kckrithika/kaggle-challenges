local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samcontrol",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "samcontrol.json": std.toString(import "configs/samcontrol-config.jsonnet"),
    },
}
