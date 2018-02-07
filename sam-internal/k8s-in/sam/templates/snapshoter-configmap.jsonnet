local configs = import "config.jsonnet";

#Keep the below if statement in sync with the one in snapshoter.jsonnet
if configs.kingdom != "prd" || configs.estate == "prd-samdev" then {
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
