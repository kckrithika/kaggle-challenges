local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.k8sproxy then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel,
    },
    data: {
        "haproxy.cfg": std.toString((import "configs/haproxy.cfg.jsonnet").data),
    },
} else "SKIP"
