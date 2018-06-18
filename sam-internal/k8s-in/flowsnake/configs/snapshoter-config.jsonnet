local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

{
  sinks: "kafka",
  sources: "informer",
  "clientKeyFile": configs.keyFile,
  "clientCertFile": configs.certFile,
  "enableKafkaClientAuth": true,
  "kube-poll-interval": "30m",
  "kafka-push-interval": "10s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  # TODO: testing currently in PRD data, uncomment when test topic permissions fixed
  # "kafka-topic": "sfdc." + (if flowsnake_config.is_test then "test" else "prod") + ".fs-k8s-snapshots__" + configs.kingdom + ".ajna_local__snapshot",
  "kafka-topic": "sfdc." + (if estate == "prd-data-flowsnake" then "test" else "prod") + ".fs-k8s-snapshots__" + configs.kingdom + ".ajna_local__snapshot",
  "ca-file": configs.caFile,
  "send-events": true,
  "liveness-probe-port": 9095,
  "ignored-resources": [],
  [if configs.kingdom == "prd" then "include-crds"]: true,
}
