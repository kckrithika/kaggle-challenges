local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  funnelEndpoint: configs.funnelVIP,
  perEstateRepairPct: 0.001,
  perEstateRepairFrequency: "30m",
  perKingdomRepairPct: 0.01,
  conditionStableTime: "35m",
  hostRegexWhitelist: (if configs.estate == "prd-samtest" then [
   ".*samtest.*",
  ] else [
    ".*cdg.*",
    ".*chx.*",
    ".*dfw.*",
    ".*fra.*",
    ".*frf.*",
    ".*hio.*",
    ".*hnd.*",
    ".*ia2.*",
    ".*iad.*",
    ".*ord.*",
    ".*par.*",
    ".*ph2.*",
    ".*phx.*",
    ".*prd.*",
    ".*syd.*",
    ".*ttd.*",
    ".*ukb.*",
    ".*xrd.*",
    ".*yhu.*",
    ".*yul.*",
    ".*ia4.*",
    ".*ia5.*",
  ]),
  actionConditions: { reboot: (if configs.estate == "prd-samtest" then ["filesystemChecker", "kubeletChecker", "cliChecker.DockerDaemon", "kubeResourcesChecker.NodeHealth", "procUpTime"] else ["filesystemChecker", "kubeletChecker", "cliChecker.DockerDaemon", "procUpTime"]) },
}) else "SKIP"
