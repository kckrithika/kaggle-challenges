local configs = import "config.jsonnet";
{
  checkImageExistsFlag: (import "./samcontrol-config.jsonnet").checkImageExistsFlag,
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then ["^[^.]+"] else ["csc-sam"]),
  resyncinterval: "60m",
  qps: 100,
  threadcount: 15,
  funnelEndpoint: configs.funnelVIP,
}
