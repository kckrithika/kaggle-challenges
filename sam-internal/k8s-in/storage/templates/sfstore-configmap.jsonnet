local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfstore-configmap",
      namespace: "sam-system",
    },
    data: {
      "sf-store-prdsam-1.10.json": std.toString(import "configs/sf-store-prdsam-1.10.jsonnet"),
    },
} else "SKIP"
