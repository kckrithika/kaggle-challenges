local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" then
std.prune({
  caFile: configs.caFile,
  dbHostname: "mysql.csc-sam." + configs.estate + ".prd.slb.sfdc.net",
  dbUsername: "root",
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  k8sResourceDbName: (if configs.estate == "prd-sam" then "sam_kube_resource" else "sam_kube_resource_test"),
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: (
    if configs.estate == "prd-samdev" then "sfdc.prod.sam__prd.ajna_local__resourcestatus"
    else "sfdc.prod.sam__cdu.ajna_local__resourcestatus,sfdc.prod.sam__chx.ajna_local__resourcestatus,sfdc.prod.sam__dfw.ajna_local__resourcestatus,sfdc.prod.sam__frf.ajna_local__resourcestatus,sfdc.prod.sam__hnd.ajna_local__resourcestatus,sfdc.prod.sam__iad.ajna_local__resourcestatus,sfdc.prod.sam__ord.ajna_local__resourcestatus,sfdc.prod.sam__par.ajna_local__resourcestatus,sfdc.prod.sam__phx.ajna_local__resourcestatus,sfdc.prod.sam__syd.ajna_local__resourcestatus,sfdc.prod.sam__ukb.ajna_local__resourcestatus,sfdc.prod.sam__wax.ajna_local__resourcestatus,sfdc.prod.sam__yhu.ajna_local__resourcestatus,sfdc.prod.sam__yul.ajna_local__resourcestatus"
    ),
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
