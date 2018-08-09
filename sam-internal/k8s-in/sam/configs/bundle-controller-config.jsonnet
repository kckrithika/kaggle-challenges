local configs = import "config.jsonnet";
{
  whiteListNamespaceRegexp: (if configs.estate == "prd-samtest" then ["^ci-*", "^user-*"] else ["^ci-*"]),
  resyncinterval: "5m",
}
