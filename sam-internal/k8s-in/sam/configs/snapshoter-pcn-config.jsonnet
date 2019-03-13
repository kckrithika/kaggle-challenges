local configs = import "config.jsonnet";

{
  sinks: "kafka",
  sources: "informer",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "client-key-file": "/cert1/client/keys/client-key.pem",
  "client-cert-file": "/cert1/client/certificates/client.pem",
  funnelEndpoint: configs.funnelVIP,
  "enable-kafka-client-auth": false,
  "kube-poll-interval": "30m",
  "kafka-push-interval": "10s",
  "kafka-payload-kb": 300,
  "kafka-endpoint": "ajna-kafka.ajnalocal1.vip.core.test.us-central1.gcp.sfdc.net:9093",
  "kafka-topic": "sfdc.test.sam__gcp.us-central1.core.ajnalocal1__resourcestatus",
  "ca-file": "/etc/pki_service/ca/cacerts.pem",
  "send-events": true,
  "liveness-probe-port": 9095,
  "ignored-resources": [],
  "include-crds": true,
}
