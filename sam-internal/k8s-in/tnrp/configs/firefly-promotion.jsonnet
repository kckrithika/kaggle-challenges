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
        'com.salesforce': 'INFO',
        'com.salesforce.firefly.promotionservice': 'DEBUG',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    rabbitmq: {
      'queue-name': '${RABBIT_MQ_QUEUE_NAME}',
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
      'instance-type': '${INSTANCE_TYPE}',
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
      'instance-type': '${INSTANCE_TYPE}',
      artifactory: artifactoryConfig.prod,
      'context-prefix': '',
      'health-check-repo': 'tnrpfirefly',
      'back-off-period': '2000ms',
    },
    local custom_monitoring_configs = {
      'enable-metrics-logging': false,
      'enable-funnel-publisher': true,
      'metric-fields' : {
        'common-tags': {
            'repo': '${INSTANCE_TYPE}',
        }
      }
    },
    firefly: {
      monitoring: std.mergePatch(monitoringConfig.monitor(serviceName), custom_monitoring_configs)
    }
  }
}