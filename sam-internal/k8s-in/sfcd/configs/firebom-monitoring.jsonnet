local configs = import "config.jsonnet";

{
  monitor(serviceName):: {
    'report-frequency': if configs.estate == 'prd-samtwo' then 1 else 1,
    'system-exception-threshold': 5,
    'metric-fields': {
      'datacenter': configs.kingdom,
      'superpod': configs.estate,
      'pod': serviceName,
      'service': 'sfcdapi-firebom',
      'subservice': '${MY_APP_NAME}',
      'common-tags': {
        'k8.namespace': '${MY_POD_NAMESPACE}',
        'k8.node.name': '${MY_NODE_NAME}',
      }
    },
    'funnel': {
      'endpoint': 'ajna0-funnel1-0-prd.data.sfdc.net',
      'http-port': 80,
      'https-port': 443,
      'funnel-api-version': 'v1',
      'base-path': 'funnel',
      'publish-api': 'publishBatch',
      'avro-schema-fingerprint': 'AVG7NnlcHNdk4t_zn2JBnQ',
      'max-publish-tries': 3,
      'backoff-time': 1,
      'ssl-enabled': false,
    }
  },

  management(port):: {
    server: {
      port: port,
    },
    endpoint: {
      health: {
        'show-details': 'always',
        enabled: true,
      },
      metrics: {
        enabled: true,
      },
    },
    endpoints: {
      'enabled-by-default': 'false',
      web: {
        exposure: {
          include: 'health, metrics',
        },
      },
    },
  },
}
