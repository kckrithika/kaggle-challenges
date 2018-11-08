local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
local rabbitConfig = import "configs/firefly-spring-rabbitmq.jsonnet";
local monitoringConfig = import "configs/firefly-monitoring.jsonnet";
local gheConfig = import "configs/firefly-ghe.jsonnet";

{
  config(serviceName):: {
     spring: {
       rabbitmq: rabbitConfig,
     },
    server: {
      port: -1,
    },
    management: monitoringConfig.management(portConfig.firefly.evalresultmonitor_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'INFO',
        'com.salesforce.firefly.evalresultmonitor': 'DEBUG',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - e=%X{eventType} sha=%X{sha} repo=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    rabbitmq: {
      'queue-name': '${RABBIT_MQ_QUEUE_NAME}',
      'eval-result-monitor-queue': '${EVAL_RESULT_MONITOR_QUEUE}',
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
    },
    appconfig: {
      'monitor-wait-time': '300000ms',
      'instance-type': '${INSTANCE_TYPE}',
      'workspace-config': {
        'root-dir': envConfig.environmentMapping[configs.estate].rootDir,
      },
      'evaluation-config': {
        'pipeline-manifest-json': '/tnrp/pipeline_manifest.json',
      },
      'context-prefix': '',
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
