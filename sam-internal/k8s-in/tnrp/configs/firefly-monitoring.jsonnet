local configs = import "config.jsonnet";

{
  monitor(serviceName):: {
    'report-frequency': 1,
    datacenter: configs.kingdom,
    superpod: 'NONE',
    pod: serviceName,
    'system-exception-threshold': 5,
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