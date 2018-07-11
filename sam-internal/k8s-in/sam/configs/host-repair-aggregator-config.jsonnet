local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then
std.prune({
  crdNamespace: "sam-system",
  crdPollFrequency: "5m",
  crdPushFrequency: "10m",
  nodeOfflineAfterTime: "30m",
  signals: [
    "filesystemChecker",
    "kubeletChecker",
  ],
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
