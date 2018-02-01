local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "snapshotconsumer",
      namespace: "sam-system",
    },
    data: {
      "snapshotconsumer.json": std.toString(import "configs/snapshotconsumer-config.jsonnet"),
    },
} else "SKIP"
