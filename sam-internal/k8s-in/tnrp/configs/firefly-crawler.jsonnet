local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
local monitoringConfig = import "configs/firefly-monitoring.jsonnet";
local gheConfig = import "configs/firefly-ghe.jsonnet";

{
  config(serviceName):: {
    spring: {
      quartz: {
        properties: {
          'org.quartz.threadPool.threadCount': 100,
        },
      },
    },
    server: {
      port: -1,
    },
    management: {
      server: {
        port: portConfig.firefly.crawler_mgmt,
      },
      endpoint: {
        health: {
          'show-details': 'always',
        },
      },
      endpoints: {
        web: {
          exposure: {
            include: '*',
          },
        },
      },
    },
    logging: {
      level: {
        org: 'INFO',
        'com.salesforce': 'INFO',
      },
      pattern: {
        console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread] %-5level - details=[%msg]  %n',
      },
    },
    scm: {
      ghe: gheConfig,
    },
    firefly: {
      crawler: {
        'job-interval-in-milliseconds': 300000,
        repositories: envConfig.environmentMapping[configs.estate].repositories,
        'since-commit-time-in-minutes': 30,
        'until-commit-time-in-minutes': 5,
        'until-commit-status-time-in-minutes': 2,
        'max-commit-retry': 10,
        'since-prr-time-in-minutes': 30,
        'until-prr-time-in-minutes': 5,
        'until-prr-status-time-in-minutes': 2,
        'max-prr-retry': 10,
        'ghe-context-prefix': '',
        'ghe-health-check-repo': 'tnrpfirefly',
      },
      intake: {
        'api-url': envConfig.environmentMapping[configs.estate].intakeEndpoint,
        'connect-timeout': '10000ms',
        'read-timeout': '10000ms',
        'write-timeout': '10000ms',
        'max-idle-connections': 10,
        'keep-alive-duration': '5m',
        'http-logging-interceptor-level': 'NONE',
      },
      monitoring: monitoringConfig.monitor(serviceName),
    },
  },
}