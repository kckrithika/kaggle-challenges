local configs = import "config.jsonnet";
{
   is_rabbitmq_enabled:
      configs.estate == "prd-samtwo" ||
#      configs.estate == "prd-samdev" ||
#      configs.estate == "prd-samtest"||
      configs.estate == "prd-sam",

   is_firefly_svc_enabled:
      configs.estate == "prd-samtwo" ||
#      configs.estate == "prd-samdev" ||
#      configs.estate == "prd-samtest" ||
      configs.estate == "prd-sam",

   is_slb_enabled:
      configs.estate == "prd-samtwo" ||
      configs.estate == "prd-sam",

}
