local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";

{
  server: {
    port: -1,
  },
  management: {
    server: {
      port: 8081,
    },
    endpoint: {
      health: {
        'show-details': 'always',
      },
    },
    endpoints: {
      web: {
        exposure: {
          include: '*',
        },
      },
    },
  },
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
    monitoring: {
      'report-frequency': 1,
      'node-name': '${RABBITMQ_NODENAME}',
      datacenter: configs.kingdom,
      superpod: 'NONE',
      pod: 'rabbitmq',
      'system-exception-threshold': 5,
    },
  },
}