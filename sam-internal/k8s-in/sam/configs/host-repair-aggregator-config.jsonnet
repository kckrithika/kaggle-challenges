local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  crdPollFrequency: "5m",
  crdPushFrequency: "10m",
  nodeOfflineAfterTime: "60m",
  k8sFromDB: true,
  k8sResourceDbName: "sam_kube_resource",
  k8sResourceTableName: "k8s_resource",
  k8sCeListFromDB: (if configs.estate == "prd-samtest" then [
          "prd-samtest",
  ] else [
          "prd-sam",
          "xrd-sam",
          "prd-samtwo",
          "frf-sam",
          "dfw-sam",
          "phx-sam",
          "yhu-sam",
  ]),
  dbHostname: (if configs.estate == "prd-samtest" then "mysql-read.sam-system.prd-sam.prd.slb.sfdc.net" else mysql.readWriteHostName),
  dbUsername: "host-repair-agg",
  dbPasswordFile: "/var/mysqlPwd/host-repair-agg",
  signals: [
    "filesystemChecker",
    "maddogCertChecker",
    "kubeletChecker",
  ],
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
