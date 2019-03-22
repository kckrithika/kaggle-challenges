local configs = import "config.jsonnet";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "rsyslog-metadata-cm",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel,
    },
    data: {
        datacenter: "mvp",
        substrate: "gcp",
        region: "us-west-1",
        zone: "a",
    },
} else "SKIP"
