local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "host-repair-scheduler",
        namespace: "sam-system",
    } + configs.ownerLabel.sam,
    data: {
        "host-repair-scheduler.json": std.toString(import "configs/host-repair-scheduler-config.jsonnet"),
    },
} else "SKIP"
