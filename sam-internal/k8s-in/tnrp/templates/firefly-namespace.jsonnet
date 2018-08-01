local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'firefly',
    labels: {} + configs.ownerLabel.tnrp,
  },
} else "SKIP"
