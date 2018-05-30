local configs = import "config.jsonnet";
local mysql = import "mysqlconfig.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_test then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.hostName,
  dbUsername: mysql.userName,
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: (
    if flowsnake_config.is_test then "sfdc.test.fs-k8s-snapshots__prd.ajna_local__snapshot"
    else "sfdc.prod.fs-k8s-snapshots__prd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__cdu.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__chx.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__dfw.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__frf.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__hnd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__iad.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__ord.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__par.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__phx.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__syd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__ukb.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__wax.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__yhu.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__yul.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__xrd.ajna_local__snapshot"
    ),
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
