local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  funnelEndpoint: configs.funnelVIP,
  perEstateRepairPct: 0.001,
  perKingdomRepairPct: 0.01,
  conditionStableTime: "60m",
  hostRegexWhitelist: [
    ".*prd.*",
  ],
  actionConditions: { reboot: ["filesystemChecker", "kubeletChecker"] },
}) else "SKIP"
