local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sloop then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sloop",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "prometheus.json": std.toString(import "configs/sloop-prometheus.jsonnet"),
        "sloop.yaml": (importstr "configs/sloop.yaml"),
    },
} else "SKIP"
