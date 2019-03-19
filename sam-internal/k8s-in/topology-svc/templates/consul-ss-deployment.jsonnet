local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

if configs.kingdom == 'mvp' then {
  apiVersion: 'extensions/v1beta1',
  kind: 'Deployment',
  metadata: {
    name: 'consul-ss',
    namespace: topologysvcNamespace,
    labels: {} + configs.pcnEnableLabel,
  },
  spec: {
    replicas: 0,
    selector: {
      matchLabels: {
        app: 'consul-ss',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'consul-ss',
        },
      },
      spec: {
        containers: [
          {
            name: 'consul',
            image: topologysvcimages.consul,
            args: [
              'agent',
              '-advertise=$(POD_IP)',
              '-bind=0.0.0.0',
              '-bootstrap-expect=1',
              '-client=0.0.0.0',
              '-datacenter=london',
              '-data-dir=/consul/data',
              '-domain=cluster.local',
              '-server',
              '-ui',
              '-disable-host-node-id',
            ],
            env: [
              {
                name: 'POD_IP',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'status.podIP',
                  },
                },
              },
            ],
          },
        ],
      },
    },
  },
} else 'SKIP'
