# This is necessary for the rabbitmq pods' hostname resolution so a rabbitmq cluster can be formed
# using static configuration

local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'rabbitmq-set',
    namespace: 'firefly',
  },
  spec: {
    selector: {
      app: 'rabbitmq',
    },
    clusterIP: 'None',
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_http,
        targetPort: portconfigs.firefly.rabbitmq_http,
      },
      {
        name: 'https',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_https,
        targetPort: portconfigs.firefly.rabbitmq_https,
      },
      {
        name: 'amqp',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_amqp,
        targetPort: portconfigs.firefly.rabbitmq_amqp,
      },
      {
        name: 'amqp-tls',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_amqps,
        targetPort: portconfigs.firefly.rabbitmq_amqps,
      },
    ],
  },
} else "SKIP"
