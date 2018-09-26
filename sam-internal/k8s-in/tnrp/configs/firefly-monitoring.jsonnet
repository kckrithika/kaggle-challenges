local configs = import "config.jsonnet";

{
  monitor(serviceName):: {
    'report-frequency': 1,
    datacenter: configs.kingdom,
    superpod: 'NONE',
    pod: serviceName,
    'system-exception-threshold': 5,
    },
}