local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.readWriteHostName,
  dbUsername: "ssc-pcn",
  dbPasswordFile: "/var/mysqlPwd/ssc-pcn",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: "sfdc.test.sam__gcp.us-central1.core.ajnalocal1__resourcestatus",
  funnelEndpoint: configs.funnelVIP,
  kafkaClientId: "snapshot-consumer-prd",
  enableKafkaClientAuth: true,
  clientKeyFile: "/cert1/client/keys/client-key.pem",
  clientCertFile: "/cert1/client/certificates/client.pem",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
}) else "SKIP"
