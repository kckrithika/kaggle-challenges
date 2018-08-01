local configs = import "config.jsonnet";
{
   is_rabbitmq_enabled:
      configs.estate == "prd-samdev" ||
      configs.estate == "prd-samtest",
}
