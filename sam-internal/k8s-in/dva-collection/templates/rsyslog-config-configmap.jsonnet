local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "rsyslog-configmap",
        namespace: "sam-system",
         labels: {} + configs.pcnEnableLabel
    },
    data: {
        "general.conf.erb": "test",
    },
} else "SKIP"