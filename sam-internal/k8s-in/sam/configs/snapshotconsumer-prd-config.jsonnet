local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.hostName,
  dbUsername: mysql.userName,
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: "sfdc.prod.sam__prd.ajna_local__resourcestatus",
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
