local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
  checkImageExistsFlag: (if utils.is_pcn(configs.kingdom) then false else (import "./samcontrol-config.jsonnet").checkImageExistsFlag),
  whiteListNamespaceRegexp: ["^[^.]+"],
  resyncinterval: "60m",
  qps: 100,
  threadcount: 15,
  funnelEndpoint: configs.funnelVIP,
  K4ASecretEnabled: true,
  statefulAppEnabled: true,
}
