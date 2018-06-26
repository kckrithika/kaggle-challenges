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
  k8sResourceDbName: (if flowsnake_config.is_test then "kube_resource_test" else "kube_resource"),
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  kafkaTopics: (
    // Test fleet only has access to the test topic
    if flowsnake_config.is_test then "sfdc.test.fs-k8s-snapshots__prd.ajna_local__snapshot"
    else "sfdc.prod.fs-k8s-snapshots__prd.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__frf.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__iad.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__ord.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__par.ajna_local__snapshot,sfdc.prod.fs-k8s-snapshots__phx.ajna_local__snapshot"
    ),
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
