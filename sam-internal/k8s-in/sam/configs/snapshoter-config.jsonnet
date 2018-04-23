local configs = import "config.jsonnet";

{
  sinks: "kafka",
  sources: "informer",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "kube-poll-interval": "30m",
  "kafka-push-interval": "10s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc.prod.sam__" + configs.kingdom + ".ajna_local__resourcestatus",
  "ca-file": configs.caFile,
  "send-events": true,
  "liveness-probe-port": 9095,
  "ignored-resources": (
    if configs.estate == "prd-samtest" then ["ReplicaSet"]
    else []
  ),
}
