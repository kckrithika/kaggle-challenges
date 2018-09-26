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
    management: {
      server: {
        port: portConfig.firefly.promotion_mgmt,
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
      artifactory: {
        'artifactory-dev-host': envConfig.environmentMapping[configs.estate].artifactoryDevHost,
        'artifactory-p2p-host': envConfig.environmentMapping[configs.estate].artifactoryP2PHost,
        'artifactory-dev-endpoint': 'https://${appconfig.artifactory.artifactory-dev-host}/',
        'artifactory-p2p-endpoint': 'https://${appconfig.artifactory.artifactory-p2p-host}/',
        'artifactory-p2p-api-endpoint': 'https://${appconfig.artifactory.artifactory-p2p-host}/artifactory/',
        'artifactory-user-name': envConfig.environmentMapping[configs.estate].artifactoryUserName,
        'artifactory-password': '${artifactoryPassword#FromSecretService}',
        'artifactory-content-repo-user-name': envConfig.environmentMapping[configs.estate].artifactoryContentRepoUserName,
        'artifactory-content-repo-password': '${artifactoryContentRepoPassword#FromSecretService}',
        'artifactory-content-repo-user-name-prod': envConfig.environmentMapping[configs.estate].artifactoryContentRepoUserNameProd,
        'socket-timeout': '30000ms',
        'connection-timeout': '20000ms',
        'max-retry': 3,
        'backoff-time': '1000ms',
      },
      'context-prefix': '',
      'health-check-repo': 'tnrpfirefly',
    },
    firefly: {
      monitoring: monitoringConfig.monitor(serviceName),
    },
  },
}