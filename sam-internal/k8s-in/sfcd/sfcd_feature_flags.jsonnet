local configs = import "config.jsonnet";
{
   is_api_enabled:
      configs.estate == "prd-samtwo",

}
