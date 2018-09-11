local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  crdPollFrequency: "5m",
  crdPushFrequency: "10m",
  nodeOfflineAfterTime: "60m",
  signals: [
    "filesystemChecker",
    "maddogCertChecker",
    "kubeletChecker",
  ],
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
