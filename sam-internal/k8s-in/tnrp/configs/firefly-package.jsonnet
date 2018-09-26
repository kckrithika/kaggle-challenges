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
        'com.salesforce': 'DEBUG',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - instanceType=${INSTANCE_TYPE} e=%X{eventType} sha=%X{sha} repo=%X{repo} c=%X{committer} - details=[%msg]  %n',
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
      'health-check-repo': 'tnrpfirefly',
    },
    firefly: {
      monitoring: monitoringConfig.monitor(serviceName),
    },
  },
}
