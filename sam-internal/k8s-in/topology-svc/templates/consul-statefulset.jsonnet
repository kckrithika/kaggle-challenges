// StatefulSet to run the actual Consul server cluster.
local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

local consulEnvParams = [
  {
    name: 'POD_IP',
    valueFrom: {
      fieldRef: {
        fieldPath: 'status.podIP',
      },
    },
  },
  {
    name: 'NAMESPACE',
    valueFrom: {
      fieldRef: {
        fieldPath: 'metadata.namespace',
      },
    },
  },
];

local ports = [
  {
    containerPort: 8500,
    name: 'http',
  },
  {
    containerPort: 8301,
    name: 'serflan',
  },
  {
    containerPort: 8302,
    name: 'serfwan',
  },
  {
    containerPort: 8300,
    name: 'server',
  },
];

if configs.kingdom == 'mvp' then {
  apiVersion: 'apps/v1beta1',
  kind: 'StatefulSet',
  metadata: {
    name: 'consul-server',
    namespace: topologysvcNamespace,
    labels: {} + configs.pcnEnableLabel,
  },
  spec: {
    serviceName: 'consul-headless',
    podManagementPolicy: 'Parallel',
    updateStrategy: {
        type: 'RollingUpdate',
    },
    replicas: 3,
    selector: {
      matchLabels: {
        app: 'consul-server',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'consul-server',
        },
      },
      spec: {
        terminationGracePeriodSeconds: 10,
        securityContext: {
            fsGroup: 7447,
            runAsNonRoot: true,
            runAsUser: 7447,
        },
        dnsPolicy: 'ClusterFirstWithHostNet',
        restartPolicy: 'Always',
        containers: [
          {
            name: 'consul',
            image: topologysvcimages.consul,
            args: [
              'agent',
              '-advertise=$(POD_IP)',
              '-bind=0.0.0.0',
              '-client=0.0.0.0',
              '-bootstrap-expect=3',
              '-datacenter=gcp-uscentral1',
              '-data-dir=/consul/data',
              '-domain=cluster.local',
              '-server',
              '-disable-host-node-id',
              '-retry-join=consul-server-0.consul-headless.$(NAMESPACE).svc',
              '-retry-join=consul-server-1.consul-headless.$(NAMESPACE).svc',
              '-retry-join=consul-server-2.consul-headless.$(NAMESPACE).svc',
            ],
            env: consulEnvParams,
            lifecycle: {
              preStop: {
                exec: {
                  command: [
                    '/bin/sh',
                    '-c',
                    'consul leave',
                  ],
                },
              },
            },
            ports: ports,
            readinessProbe: {
              exec: {
                command: [
                  'curl http://$POD_IP:8500/v1/status/leader 2>/dev/null | grep -E \'".+"\'',
                ],
              },
              failureThreshold: 2,
              initialDelaySeconds: 5,
              periodSeconds: 3,
              successThreshold: 1,
              timeoutSeconds: 5,
            },
            securityContext: {
                runAsNonRoot: true,
                runAsUser: 7447,
            },
          },
        ],
      },
    },
  },
} else 'SKIP'
