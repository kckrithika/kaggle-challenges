local configs = import "config.jsonnet";
if configs.estate == "prd-sam"  then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "casam-sequencer-serviceaccount",
    namespace: "core-on-sam-sp2",
  },
} else "SKIP"
