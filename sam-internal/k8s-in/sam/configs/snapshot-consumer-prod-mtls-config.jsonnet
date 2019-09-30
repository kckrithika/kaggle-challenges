local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

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
  kingdoms:: ["cdg", "cdu", "chx", "dfw", "fra", "frf", "hio", "hnd", "ia2", "ia4", "ia5", "iad", "lo2", "lo3", "ord", "par", "ph2", "phx", "prd", "syd", "ttd", "ukb", "wax", "xrd", "yhu", "yul"],
  kafkaTopics: std.join(",", ["sfdc.prod.sam__" + x + ".ajna_local__resourcestatus" for x in self.kingdoms]),
  funnelEndpoint: configs.funnelVIP,
  enableKafkaClientAuth: true,
  kafkaClientId: "snapshot-consumer-prod",
  clientKeyFile: "/cert1/client/keys/client-key.pem",
  clientCertFile: "/cert1/client/certificates/client.pem",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
}) else "SKIP"
