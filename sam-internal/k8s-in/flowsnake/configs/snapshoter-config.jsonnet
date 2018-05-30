local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

{
  sinks: "kafka",
  sources: "informer",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "kube-poll-interval": "30m",
  "kafka-push-interval": "10s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc." + (if flowsnake_config.is_test then "test" else "prod") + ".fs-k8s-snapshots__" + configs.kingdom + ".ajna_local__snapshot",
  "ca-file": configs.caFile,
  "send-events": true,
  "liveness-probe-port": 9095,
  "ignored-resources": [],
  [if configs.kingdom == "prd" then "include-crds"]: true,
}
