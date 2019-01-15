local configs = import "config.jsonnet";
{
  checkImageExistsFlag: (import "./samcontrol-config.jsonnet").checkImageExistsFlag,
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then ["^[^.]+"] else if configs.kingdom == "frf" then ["csc-sam"] else ["^ci-*"]),
  resyncinterval: "60m",
  qps: 100,
  threadcount: 15,
  funnelEndpoint: configs.funnelVIP,
}
