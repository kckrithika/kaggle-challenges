local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
local monitoringConfig = import "configs/firefly-monitoring.jsonnet";

{
  server: {
    port: -1,
  },
  management: monitoringConfig.management(portConfig.firefly.rabbitmq_health),
  logging: {
    level: {
      org: 'INFO',
      'com.salesforce': 'DEBUG',
    },
    pattern: {
      console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - details=[%msg]  %n',
    },
  },
  firefly: {
    rabbitmqapi: {
      'api-url': 'http://localhost:' + portConfig.firefly.rabbitmq_http,
      user: envConfig.environmentMapping[configs.estate].rabbitMqUserName,
      password: '${rabbitMqDefaultPass#FromSecretService}',
      'connect-timeout': '10000ms',
      'read-timeout': '10000ms',
      'write-timeout': '10000ms',
      'max-idle-connections': 10,
      'keep-alive-duration': '300000ms',
      'http-logging-interceptor-level': 'NONE',
      'cluster-size': 2,
    },
    local custom_monitoring_configs = {
      'enable-metrics-logging': false,
      'enable-funnel-publisher': true,
      'node-name': '${RABBITMQ_NODENAME}',
      'metric-fields' : {
        'subservice': 'firefly-rabbitmq',
        'common-tags': {
          'node.name': '${RABBITMQ_NODENAME}',
        }
      }
    },
    monitoring: std.mergePatch(monitoringConfig.monitor('\'${MY_POD_NAME}\''), custom_monitoring_configs)
  },
}