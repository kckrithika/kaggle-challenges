local configs = import "config.jsonnet";
local firefly_feature_flags = import "sfcd_feature_flags.jsonnet";

if sfcd_feature_flags.is_api_enabled then {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'sfcdapi',
    labels: {} + configs.ownerLabel.sfcd,
  },
} else "SKIP"
