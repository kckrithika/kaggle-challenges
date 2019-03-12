local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
  caFile: configs.caFile,
  dbHostname: mysql.readWriteHostName,
  dbUsername: "ssc-prod",
  dbPasswordFile: "/var/mysqlPwd/ssc-prod",
  k8sResourceDbName: mysql.visibilityDBName,
  k8sResourceTableName: "k8s_resource",
  consumeTableName: "consume",
  kafkaConsumerEndpoint: "ajna0-brokeragg1-0-prd.data.sfdc.net:9093",
  kafkaTopics: "sfdc.test.sam__gcp.us-central1.core.ajnalocal1__resourcestatus,sfdc.prod.sam__cdu.ajna_local__resourcestatus,sfdc.prod.sam__chx.ajna_local__resourcestatus,sfdc.prod.sam__dfw.ajna_local__resourcestatus,sfdc.prod.sam__frf.ajna_local__resourcestatus,sfdc.prod.sam__hnd.ajna_local__resourcestatus,sfdc.prod.sam__iad.ajna_local__resourcestatus,sfdc.prod.sam__ord.ajna_local__resourcestatus,sfdc.prod.sam__par.ajna_local__resourcestatus,sfdc.prod.sam__phx.ajna_local__resourcestatus,sfdc.prod.sam__syd.ajna_local__resourcestatus,sfdc.prod.sam__ukb.ajna_local__resourcestatus,sfdc.prod.sam__wax.ajna_local__resourcestatus,sfdc.prod.sam__yhu.ajna_local__resourcestatus,sfdc.prod.sam__yul.ajna_local__resourcestatus,sfdc.prod.sam__xrd.ajna_local__resourcestatus,sfdc.prod.sam__cdg.ajna_local__resourcestatus,sfdc.prod.sam__fra.ajna_local__resourcestatus,sfdc.prod.sam__ia2.ajna_local__resourcestatus,sfdc.prod.sam__lo2.ajna_local__resourcestatus,sfdc.prod.sam__lo3.ajna_local__resourcestatus,sfdc.prod.sam__ph2.ajna_local__resourcestatus",
  funnelEndpoint: configs.funnelVIP,
  enableKafkaClientAuth: true,
  kafkaClientId: "snapshot-consumer-prod",
  clientKeyFile: "/cert1/client/keys/client-key.pem",
  clientCertFile: "/cert1/client/certificates/client.pem",
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
}) else "SKIP"
