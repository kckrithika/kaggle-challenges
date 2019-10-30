local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

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
    ".*" + kingdom + ".*"
    for kingdom in utils.get_all_kingdoms()
    if !std.setMember(kingdom, ["cdu", "chd", "lo2", "lo3", "wax"])
  ]),
  actionConditions: { reboot: (if configs.estate == "prd-samtest" then ["filesystemChecker", "kubeletChecker", "cliChecker.DockerDaemon", "kubeResourcesChecker.NodeHealth", "procUpTime"] else ["filesystemChecker", "kubeletChecker", "cliChecker.DockerDaemon", "procUpTime"]) },
}) else "SKIP"
