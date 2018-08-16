local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  kind: 'PersistentVolume',
  apiVersion: 'v1',
  metadata: {
    name: 'firefly-rabbitmq-pv-volume',
    namespace: 'firefly',
    labels: {
      type: 'local',
    },
  },
  spec: {
    storageClassName: 'manual',
    capacity: {
      storage: '100Gi',
    },
    accessModes: [
      'ReadWriteOnce',
    ],
    hostPath: {
      path: '/data/firefly',
    },
  },
} else "SKIP"
