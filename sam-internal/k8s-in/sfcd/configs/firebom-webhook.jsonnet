local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local sfcd_feature_flags = import "sfcd_feature_flags.jsonnet";
local envConfig = import "configs/firebom_service_conf.jsonnet";
local monitoringConfig = import "configs/firebom-monitoring.jsonnet";
local gheConfig = import "configs/firebom-ghe.jsonnet";
local templatesRepoConfig = import "configs/firebom-templates-repo.jsonnet";
local templatesCompositionConfig = import "configs/firebom-templates-composition.jsonnet";

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
        console: "%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread gua=%X{userAgent} ghd=%X{gitHubDelivery}] %-5level - e=%X{eventType} sha=%X{sha} repo=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n"
      },
    },
    scm: {
      ghe: gheConfig,
    },
    templates: {
      repo: templatesRepoConfig,
    },
    pipeline: {
      templates: {
        composition: templatesCompositionConfig,
      }
    },
    sfcdapi: {
      firebom: {
        pipeline: {
          template: {
            'enable-webhook-secret': false,
            'fire-bom-white-list': "lib/fire/.*/boms/hydrated.*json",
            'fire-bom-black-list': "lib/fire/.*/boms/mock.*json",
          }
        }
      },
      ghe: {
        'commit-signing': false,
        'webhook-secret-token-validation': false,
        'context-prefix': "",
      },
    },
    local custom_monitoring_configs = {
      'enable-metrics-logging': false,
      'enable-funnel-publisher': true,
    },
    monitoring: std.mergePatch(monitoringConfig.monitor(serviceName), custom_monitoring_configs)
  }
}
