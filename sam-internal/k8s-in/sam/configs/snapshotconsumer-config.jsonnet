local samimages = import "samimages.jsonnet";
local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
{
  caFile: configs.caFile,
  dbHostname: "mysql.csc-sam." + configs.estate + ".prd.slb.sfdc.net",
  dbUsername: "root",
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  k8sResourceDbName: "sam_kube_resource",
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: "sfdc.prod.sam__prd.ajna_local__resourcestatus,sfdc.prod.sam__frf.ajna_local__resourcestatus,sfdc.prod.sam__dfw.ajna_local__resourcestatus,sfdc.prod.sam__phx.ajna_local__resourcestatus",
  funnelEndpoint: configs.funnelVIP,
} else "SKIP"
