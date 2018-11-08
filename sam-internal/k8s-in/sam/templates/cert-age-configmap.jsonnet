local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kubedns then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "cert-age",
        namespace: "kube-system",
    },
    data: import "configs/cert-age.jsonnet",
} else "SKIP"
