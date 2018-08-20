local configs = import "config.jsonnet";
{
   is_rabbitmq_enabled:
      configs.estate == "prd-samtwo" ||
      configs.estate == "prd-sam" ||
      configs.estate == "prd-samdev" ||
      configs.estate == "prd-samtest",

   is_slb_enabled:
      configs.estate == "prd-sam",

}
