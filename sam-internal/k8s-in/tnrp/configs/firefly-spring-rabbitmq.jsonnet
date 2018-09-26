local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";

{
  host: envConfig.environmentMapping[configs.estate].rabbitMqEndpoint,
  port: portConfig.firefly.rabbitmq_amqp,
  username: envConfig.environmentMapping[configs.estate].rabbitMqUserName,
  password: '${rabbitMqDefaultPass#FromSecretService}',
  'publisher-confirms': true,
  'publisher-returns': true,
  template: {
    mandatory: true,
    'reply-timeout': '60000ms',
    retry: {
      enabled: true,
      'max-attempts': 10,
      multiplier: 2,
      'initial-interval': '1000ms',
      'max-interval': '10000ms',
    },
  },
  'connection-timeout': '10000ms',
  listener: {
    simple: {
      retry: {
        enabled: true,
        'initial-interval': '1000ms',
        'max-attempts': 3,
        'max-interval': '10000ms',
        multiplier: 2,
        stateless: true,
      },
    },
  },
}