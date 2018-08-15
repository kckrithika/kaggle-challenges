local configs = import "config.jsonnet";
{
  checkImageExistsFlag: (import "./samcontrol-config.jsonnet").checkImageExistsFlag,
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" then ["^ci-*", "^user-*"] else ["^ci-*"]),
  resyncinterval: "5m",
  funnelEndpoint: configs.funnelVIP,
}
