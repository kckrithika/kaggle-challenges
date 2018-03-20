local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
  sinks: "kafka",
  sources: "informer",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "kube-poll-interval": "5m",
  "kafka-push-interval": "5s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc.prod.sam__" + configs.kingdom + ".ajna_local__resourcestatus",
  "ca-file": configs.caFile,
  "send-events": true,
  "liveness-probe-port": 9095,
} else {
  recipient: "sam@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  kafkaEndpoint: "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc.prod.sam__" + configs.kingdom + ".ajna_local__resourcestatus",
}
