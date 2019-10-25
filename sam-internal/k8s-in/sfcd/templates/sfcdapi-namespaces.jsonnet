local configs = import "config.jsonnet";
local sfcd_feature_flags = import "sfcd_feature_flags.jsonnet";

if sfcd_feature_flags.is_firebom_webhook_enabled then {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'sfcdapi-firebom',
    labels: {} + configs.ownerLabel.sfcd,
  },
} else "SKIP"
