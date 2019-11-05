local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "pseudo-kubeapi",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "pseudo-kubeapi.json": std.toString(import "configs/pseudo-kubeapi-config.jsonnet"),
    },
} else "SKIP"
