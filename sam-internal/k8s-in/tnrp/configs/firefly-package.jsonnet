local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
local rabbitConfig = import "configs/firefly-spring-rabbitmq.jsonnet";
local monitoringConfig = import "configs/firefly-monitoring.jsonnet";
local gheConfig = import "configs/firefly-ghe.jsonnet";
local artifactoryConfig = import "configs/firefly-artifactory.jsonnet";
local dockerConfig = import "configs/firefly-docker.jsonnet";

{
  config(serviceName):: {
    spring: {
      rabbitmq: rabbitConfig,
    },
    server: {
      port: -1,
    },
    management: monitoringConfig.management(portConfig.firefly.package_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'INFO',
        'com.salesforce.firefly': 'DEBUG',
        'com.salesforce.firefly.metrics': 'INFO',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - e=%X{eventType} sha=%X{sha} repo=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    rabbitmq: {
      'package-q': '${PACKAGE_QUEUE}',
      'promotion-q': '${PROMOTION_QUEUE}',
      'latestfile-q': '${LATEST_FILE_QUEUE}',
      'service-mode': '${SERVICE_MODE}',
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
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
      'max-latency': '600000ms',
      'root-dir': envConfig.environmentMapping[configs.estate].rootDir,
      'instance-type': '${INSTANCE_TYPE}',
      'service-mode': '${SERVICE_MODE}',
      'max-attempts': 4,
      'back-off-period': '2000ms',
      security: {
        'secret-service-url': 'secretservice.dmz.salesforce.com',
      },
      docker: dockerConfig,
      artifactory: artifactoryConfig.prod,
      'context-prefix': '',
      'deliver-to-gcp': 'true',
      'image-promotion-yaml': 'image-promotion.yaml',
      'multi-repo-supported': false,
      'gus': {
            'username': '${gusUserName#FromSecretService}',
            'password': '${gusUserPassword#FromSecretService}',
            'use_proxy': true,
            'enable_gus_case_check': false,
            'enforce_gus_case_check': false,
      },
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
