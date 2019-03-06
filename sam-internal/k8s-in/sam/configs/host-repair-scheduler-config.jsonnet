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
    ".*dfw.*",
    ".*frf.*",
    ".*iad.*",
    ".*ord.*",
    ".*ph2.*",
    ".*phx.*",
    ".*prd.*",
    ".*xrd.*",
    ".*ukb.*",
    ".*yhu.*",
  ]),
  actionConditions: { reboot: ["filesystemChecker", "kubeletChecker", "cliChecker.DockerDaemon", "procUpTime"] },
}) else "SKIP"
