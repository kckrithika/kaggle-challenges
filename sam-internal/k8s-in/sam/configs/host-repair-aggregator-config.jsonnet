local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  crdPollFrequency: "5m",
  crdPushFrequency: "10m",
  nodeOfflineAfterTime: "60m",
  k8sFromDB: true,
  k8sResourceDbName: "sam_kube_resource",
  k8sResourceTableName: "k8s_resource",
  k8sCeListFromDB: [
          "prd-sam",
          "xrd-sam",
          "prd-samtwo",
          "frf-sam",
  ],
  dbPasswordFile: "/var/mysqlPwd/pass.txt",
  signals: [
    "filesystemChecker",
    "maddogCertChecker",
    "kubeletChecker",
  ],
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
