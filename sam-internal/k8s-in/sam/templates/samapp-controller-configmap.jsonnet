local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "vpod" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samapp-controller",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "samapp-controller-config.json": std.toString(import "configs/samapp-controller-config.jsonnet"),
    },
} else "SKIP"
