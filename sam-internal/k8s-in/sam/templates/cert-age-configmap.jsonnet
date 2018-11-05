local configs = import "config.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "xrd" || configs.kingdom == "ord" || configs.kingdom == "frf" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "cert-age",
        namespace: "kube-system",
    },
    data: import "configs/cert-age.jsonnet",
} else "SKIP"
