local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_flowsnake_cluster(configs.estate) then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "cert-age",
        namespace: "kube-system",
    },
    data: import "configs/cert-age.jsonnet",
} else "SKIP"
