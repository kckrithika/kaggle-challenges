local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";

if samfeatureflags.kafkaConsumer then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.dbHostname,
  dbUsername: "ssc-prod",
  dbPasswordFile: "/var/mysqlPwd/ssc-prod",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kingdoms:: utils.get_all_kingdoms(),
  kafkaTopics: std.join(",", ["sfdc.prod.sam__" + x + ".ajna_local__resourcestatus" for x in self.kingdoms]),
  funnelEndpoint: configs.funnelVIP,
  enableKafkaClientAuth: true,
  kafkaClientId: "snapshot-consumer-prod",
  clientKeyFile: "/cert1/client/keys/client-key.pem",
  clientCertFile: "/cert1/client/certificates/client.pem",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
}) else "SKIP"
