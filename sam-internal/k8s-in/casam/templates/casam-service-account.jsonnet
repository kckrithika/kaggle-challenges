local configs = import "config.jsonnet";
if configs.estate == "prd-sam"  then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "casamserviceaccount",
    namespace: "core-on-sam-sp2",
  },
} else "SKIP"
