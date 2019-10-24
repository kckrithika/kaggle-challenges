local configs = import "config.jsonnet";
{
   is_firebom_api_enabled:
      configs.estate == "prd-samtwo",

}
