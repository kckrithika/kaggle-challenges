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
    management: monitoringConfig.management(portConfig.firefly.pullrequest_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'DEBUG',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - instanceType=${instanceType} e=%X{eventType} sha=%X{sha} repo=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    rabbitmq: {
      'queue-name': '${rabbitmqQueueName}',
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
    },
    appconfig: {
      'instance-type': '${instanceType}',
      'workspace-config': {
        'root-dir': envConfig.environmentMapping[configs.estate].rootDir,
      },
      'evaluation-config': {
        'pipeline-manifest-json': '/tnrp/pipeline_manifest.json',
      },
      docker: dockerConfig,
      artifactory: artifactoryConfig.base,
      'context-prefix': '',
      'health-check-repo': 'tnrpfirefly',
    },
    firefly: {
      monitoring: monitoringConfig.monitor(serviceName),
    },
  },
}