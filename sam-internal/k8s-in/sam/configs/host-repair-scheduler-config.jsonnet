local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then
std.prune({
  crdNamespace: "sam-system",
  funnelEndpoint: configs.funnelVIP,
}) else "SKIP"
