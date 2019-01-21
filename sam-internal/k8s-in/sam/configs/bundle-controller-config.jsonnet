local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
  checkImageExistsFlag: (if utils.is_pcn(configs.kingdom) then false else (import "./samcontrol-config.jsonnet").checkImageExistsFlag),
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" || utils.is_pcn(configs.kingdom) then ["^[^.]+"] else ["csc-sam"]),
  resyncinterval: "60m",
  qps: 100,
  threadcount: 15,
  funnelEndpoint: configs.funnelVIP,
  [if configs.kingdom == "prd" then "statefulAppEnabled"]: true,
}
