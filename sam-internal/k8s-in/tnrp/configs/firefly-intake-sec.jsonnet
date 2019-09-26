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
      port: portConfig.firefly.intake_http,
    },
    management: monitoringConfig.management(portConfig.firefly.intake_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'INFO',
        'com.salesforce.firefly': 'DEBUG',
        'com.salesforce.firefly.metrics': 'INFO',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread gua=%X{userAgent} ghd=%X{gitHubDelivery}] %-5level - e=%X{eventType} sha=%X{sha} repo=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    firefly: {
      intake: {
        'repo-config-map': {
          'tnrpfirefly-test_sam_manifests': {
            'handle-only-latest-commit': true,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'tnrpfirefly-test_manifest_driven_promotions': {
            'handle-only-latest-commit': false,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'tnrp_manifest_driven_promotions': {
            'handle-only-latest-commit': false,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'sam-test-firefly-manifests': {
            'handle-only-latest-commit': true,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'sam-test-manifests': {
            'handle-only-latest-commit': true,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'test-manifests': {
            'handle-only-latest-commit': true,
            'webhook-secret-token': 'feature_not_enabled',
          },
          'manifests': {
            'handle-only-latest-commit': true,
            'webhook-secret-token': 'feature_not_enabled',
          },
        },
        'enable-webhook-secret': true
      },
      'dark-launch': '${DARKLAUNCH}',
      rabbitmq: {
        'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
        'routing-key-format': envConfig.environmentMapping[configs.estate].routingKeyFormat,
      },
      ghe: {
        'webhook-secret-token-validation': envConfig.environmentMapping[configs.estate].webHookSecretTokenValidationEnabled,
        'commit-signing': false,
        'context-prefix': '',
      },
      local custom_monitoring_configs = {
        'enable-metrics-logging': false,
        'enable-funnel-publisher': true,
      },
      monitoring: std.mergePatch(monitoringConfig.monitor(serviceName), custom_monitoring_configs)
    }
  }
}
