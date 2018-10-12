local configs = import "config.jsonnet";

{
  monitor(serviceName):: {
  // Keeping existing monitoring configs till latest changes are deployed to prd-samtwo
  // TODO: Remove these once funnel reporter has been enabled in prd-samtwo
  'datacenter': configs.kingdom,
  'superpod': 'NONE',
  'pod': serviceName,
  'report-frequency': if configs.estate == 'prd-samtwo' then 1 else 60,
  'system-exception-threshold': 5,
    'metric-fields': {
      'datacenter': configs.kingdom,
      'superpod': configs.estate,
      'pod': serviceName,
      'service': 'firefly',
      'subservice': '${MY_APP_NAME}',
      'common-tags': {
          'k8.namespace': '${MY_POD_NAMESPACE}',
          'k8.pod.name ': '${MY_POD_NAME}',
          'k8.node.name': '${MY_NODE_NAME}',
          'k8.pod.ip': '${MY_POD_IP}'
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
      'ssl-enabled': true,
    }
  },

  management(port):: {
    server: {
      port: port,
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
}
