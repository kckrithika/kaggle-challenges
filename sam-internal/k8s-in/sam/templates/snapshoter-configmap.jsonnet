local configs = import "config.jsonnet";

if configs.estate == "frf-sam" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "snapshoter",
      namespace: "sam-system",
    },
    data: {
      "snapshoter.json": std.toString(import "configs/snapshoter-config.jsonnet"),
    },
} else "SKIP"
