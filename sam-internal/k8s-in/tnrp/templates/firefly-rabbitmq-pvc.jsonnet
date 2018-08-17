local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  kind: 'PersistentVolumeClaim',
  apiVersion: 'v1',
  metadata: {
    name: 'firefly-rabbitmq-pv-claim',
    namespace: 'firefly',
  },
  spec: {
    storageClassName: 'manual',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '50Gi',
      },
    },
  },
} else "SKIP"
