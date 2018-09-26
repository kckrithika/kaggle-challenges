local envConfig = import "configs/firefly_service_conf.jsonnet";
local configs = import "config.jsonnet";

{
  'remote-docker-host': envConfig.environmentMapping[configs.estate].dockerHost,
  'docker-cert-path': envConfig.environmentMapping[configs.estate].dockerCertPath,
  'read-timeout': '480000ms',
  'connect-timeout': '480000ms',
}