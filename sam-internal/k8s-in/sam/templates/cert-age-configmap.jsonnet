local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "xrd-sam" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "cert-age",
        namespace: "kube-system",
    },
    data: import "configs/cert-age.jsonnet",
} else "SKIP"
