local configs = import "config.jsonnet";

{
  sinks: "kafka",
  sources: "informer",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "client-key-file": "/cert1/client/keys/client-key.pem",
  "client-cert-file": "/cert1/client/certificates/client.pem",
  "enable-kafka-client-auth": true,
  "kube-poll-interval": "30m",
  "kafka-push-interval": "10s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc.prod.sam__" + configs.kingdom + ".ajna_local__resourcestatus",
  "ca-file": configs.caFile,
  "send-events": true,
  "liveness-probe-port": 9095,
  "ignored-resources": [],
  "include-crds": true,
}
