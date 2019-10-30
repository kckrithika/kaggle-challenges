local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  crdPollFrequency: "5m",
  crdPushFrequency: "5m",
  nodeOfflineAfterTime: "60m",
  k8sFromDB: true,
  k8sResourceDbName: "sam_kube_resource",
  k8sResourceTableName: "k8s_resource",
  k8sCeListFromDB: (if configs.estate == "prd-samtest" then [
          "prd-samtest",
  ] else [
          estate
          for estate in utils.get_all_estates()
  ]),
  dbHostname: mysql.dbHostname,
  dbUsername: "host-repair-agg",
  dbPasswordFile: "/var/mysqlPwd/host-repair-agg",
  signals: [
    "filesystemChecker",
    "kubeletChecker",
    "cliChecker.DockerDaemon",
    "procUpTime",
  ],
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
