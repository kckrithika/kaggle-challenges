local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kafkaConsumer then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.dbHostname,
  dbUsername: "ssc-prd",
  dbPasswordFile: "/var/mysqlPwd/ssc-prd",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: "sfdc.prod.sam__prd.ajna_local__resourcestatus",
  funnelEndpoint: configs.funnelVIP,
  kafkaClientId: "snapshot-consumer-prd",
  enableKafkaClientAuth: true,
  clientKeyFile: "/cert1/client/keys/client-key.pem",
  clientCertFile: "/cert1/client/certificates/client.pem",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
}) else "SKIP"
