local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local envConfig = import "configs/firefly_service_conf.jsonnet";
{
  spring: {
    rabbitmq: {
      host: envConfig.environmentMapping[configs.estate].rabbitMqEndpoint,
      port: portConfig.firefly.rabbitmq_amqp,
      username: envConfig.environmentMapping[configs.estate].rabbitMqUserName,
      password: '${rabbitMqDefaultPass#FromSecretService}',
      'publisher-confirms': true,
      'publisher-returns': true,
      template: {
        mandatory: true,
        'reply-timeout': '60000ms',
        retry: {
          enabled: true,
          'max-attempts': 10,
          multiplier: 2,
          'initial-interval': '1000ms',
          'max-interval': '10000ms',
        },
      },
      'connection-timeout': '10000ms',
      listener: {
        simple: {
          retry: {
            enabled: true,
            'initial-interval': '1000ms',
            'max-attempts': 3,
            'max-interval': '10000ms',
            multiplier: 2,
            stateless: true,
          },
        },
      },
    },
  },
  server: {
    port: portConfig.firefly.intake_http,
  },
  management: {
    server: {
      port: portConfig.firefly.intake_mgmt,
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
      console: '%d{yyyy-MM-dd HH:mm:ss} - %C:%L[%thread gua=%X{userAgent} ghd=%X{gitHubDelivery}] %-5level - e=%X{eventType} SHA=%X{SHA} REPO=%X{repo} pr=%X{pr} c=%X{committer} - details=[%msg]  %n',
    },
  },
  scm: {
    ghe: {
      'api-url': 'https://git.soma.salesforce.com/api/v3/',
      user: 'svc-tnrp-git-rw',
      'oauth-token': '${gitRWPassword#FromSecretService}',
      'connect-timeout': '60000ms',
      'read-timeout': '60000ms',
      'write-timeout': '60000ms',
      'max-idle-connections': 10,
      'keep-alive-duration': '60000ms',
      'http-logging-interceptor-level': 'NONE',
    },
  },
  firefly: {
    intake: {
      'repo-config-map': {
        'tnrpfirefly-test_sam_manifests': {
          'handle-only-latest-commit': true,
          'webhook-secret-token': '${tnrpfireflyTestSamManifests#FromSecretService}',
        },
        'tnrpfirefly-test_manifest_driven_promotions': {
          'handle-only-latest-commit': true,
          'webhook-secret-token': '${tnrpfireflyTestManifestDrivenPromotions#FromSecretService}',
        },
        'sam-test-firefly-manifests': {
          'handle-only-latest-commit': true,
          'webhook-secret-token': '${samTestFireflyManifests#FromSecretService}',
        },
        'sam-test-manifests': {
          'handle-only-latest-commit': true,
          'webhook-secret-token': '${samTestManifests#FromSecretService}',
        },
      },
    },
    monitoring: {
      'report-frequency': 1,
      datacenter: configs.kingdom,
      superpod: 'NONE',
      pod: 'firefly-intake',
      'system-exception-threshold': 5,
    },
    rabbitmq: {
      'exchange-name': envConfig.environmentMapping[configs.estate].exchangeName,
      'prr-routing-key-format': '%s.pr',
      'push-routing-key-format': '%s.package',
    },
    ghe: {
      'webhook-secret-token-validation': envConfig.environmentMapping[configs.estate].webHookSecretTokenValidationEnabled,
      'commit-signing': false,
      'context-prefix': '',
      'health-check-repo': 'tnrpfirefly',
    },
  },
}