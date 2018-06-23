local configs = import "config.jsonnet";
local mysql = import "mysqlconfig.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

if estate == "prd-data-flowsnake" then
std.prune({
  caFile: configs.caFile,
  enableKafkaClientAuth: true,
  clientCertFile: configs.certFile,
  clientKeyFile: configs.keyFile,
  dbHostname: mysql.hostName,
  dbUsername: mysql.userName,
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  # TODO: testing currently in PRD data, uncomment when test topic permissions fixed
  # k8sResourceDbName: (if flowsnake_config.is_test then "kube_resource_test" else "kube_resource"),
  k8sResourceDbName: (if estate == "prd-data-flowsnake" then "kube_resource_test" else "kube_resource"),
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: (if flowsnake_config.is_test then "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093" else "ajna0-brokeragg1-0-prd.data.sfdc.net:9093"),
  kafkaTopics: (
    if flowsnake_config.is_test then "sfdc.test.fs-k8s-snapshots__prd.ajna_local__snapshot"
    else "sfdc.prod.fs-k8s-snapshots__prd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__cdu.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__chx.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__dfw.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__frf.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__hnd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__iad.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__ord.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__par.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__phx.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__syd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__ukb.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__wax.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__yhu.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__yul.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__xrd.ajna_local__snapshot"
    ),
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
