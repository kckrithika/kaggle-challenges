local configs = import "config.jsonnet";
local ocagentConf = importstr "configs/ocagent/opencensus.cadvisor.kubelet.yaml.erb";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "ocagent-configmap",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel,
    },
    data: {
        "opencensus.cadvisor.kubelet.yaml.erb": ocagentConf,
    },
} else "SKIP"
