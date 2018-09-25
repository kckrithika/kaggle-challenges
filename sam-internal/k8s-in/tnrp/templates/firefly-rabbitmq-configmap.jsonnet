local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'rabbitmq-configmap',
    namespace: 'firefly',
    labels: {} + configs.ownerLabel.tnrp,
  },
  data: {
    enabled_plugins: importstr 'configs/firefly-rabbitmq-plugins',
    "rabbitmq-env.conf": importstr 'configs/firefly-rabbitmq-env.conf',
    "definitions.json": std.manifestJson(import "configs/firefly-rabbitmq-definitions.jsonnet"),
    "rabbitmq.conf": (importstr 'configs/firefly-rabbitmq.conf') % { domain: 'rabbitmq-set.firefly.svc.' + configs.estate + '.' + configs.kingdom + '.sam.sfdc.net.' },
    "application.yml": std.manifestJson(import "configs/firefly-rabbitmq-monitord.jsonnet"),
  },
} else "SKIP"
