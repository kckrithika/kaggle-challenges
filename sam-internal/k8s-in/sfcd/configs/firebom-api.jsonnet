local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local sfcd_feature_flags = import "sfcd_feature_flags.jsonnet";
local envConfig = import "configs/sfcdapi-firebom_service_conf.jsonnet";
local monitoringConfig = import "configs/sfcdapi-firebom-monitoring.jsonnet";
local gheConfig = import "configs/sfcdapi-firebom-ghe.jsonnet";

{
  config(serviceName):: {
    server: {
      port: portConfig.sfcdapi.firebom_http,
    },
    management: monitoringConfig.management(portConfig.sfcdapi.firebom_mgmt),
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'INFO',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level%n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    templates: {
      repo: templatesRepoConfig,
    },
    sfcdapi: {
      firebom: {
        template: {
          'enable-webhook-secret': false
          'fire-bom-regex': "lib/fire/.*/boms/.*json"
        }
      },
      local custom_monitoring_configs = {
        'enable-metrics-logging': false,
        'enable-funnel-publisher': true,
      },
      monitoring: std.mergePatch(monitoringConfig.monitor(serviceName), custom_monitoring_configs)
    }
  }
}
