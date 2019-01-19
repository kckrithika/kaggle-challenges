{
  local configs = import "config.jsonnet",

  istioEstate: (
    if configs.estate == "prd-samtest" then
      configs.estate
    else
      configs.estate + "_gater"
  ),
}
