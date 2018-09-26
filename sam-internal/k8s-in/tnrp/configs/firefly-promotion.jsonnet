local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
local rabbitConfig = import "configs/firefly-spring-rabbitmq.jsonnet";
local monitoringConfig = import "configs/firefly-monitoring.jsonnet";
local gheConfig = import "configs/firefly-ghe.jsonnet";
local artifactoryConfig = import "configs/firefly-artifactory.jsonnet";

{
  config(serviceName):: {
    spring: {
      rabbitmq: rabbitConfig,
    },
    server: {
      port: -1,
    },
    management: monitoringConfig.management(portConfig.firefly.promotion_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'DEBUG',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - instanceType=${instanceType} - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    rabbitmq: {
      'queue-name': '${rabbitmqQueueName}',
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
      'instance-type': '${instanceType}',
    },
    appconfig: {
      'repo-config': {
        manifests: {
          type: 'content_and_artifacts',
        },
        manifest_driven_promotions: {
          type: 'artifacts',
        },
      },
      'instance-type': '${instanceType}',
      artifactory: artifactoryConfig.prod,
      'context-prefix': '',
      'health-check-repo': 'tnrpfirefly',
    },
    firefly: {
      monitoring: monitoringConfig.monitor(serviceName),
    },
  },
}