local configs = import "config.jsonnet";
{
   is_firebom_webhook_enabled:
      configs.estate == "prd-samtwo",

   is_slb_enabled:
      configs.estate == "prd-samtwo",
}
