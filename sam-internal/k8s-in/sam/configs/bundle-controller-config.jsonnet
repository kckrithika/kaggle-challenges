local configs = import "config.jsonnet";
{
  checkImageExistsFlag: (import "./samcontrol-config.jsonnet").checkImageExistsFlag,
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then ["^[^.]+"] else if configs.estate == "prd-sam" then ["^ci-*", "^user-*", "moe", "csc-sam"] else ["^ci-*"]),
  resyncinterval: "5m",
  funnelEndpoint: configs.funnelVIP,
}
