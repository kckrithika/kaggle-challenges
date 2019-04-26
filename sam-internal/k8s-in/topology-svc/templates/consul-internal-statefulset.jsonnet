// StatefulSet to run the actual Consul server cluster.
local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local madkub = (import 'topology-svc-madkub.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';
local serviceMesh = (import 'topology-svc-sherpa.jsonnet') + { templateFilename:: std.thisFile };

local certDirs = ['cert1', 'client-certs', 'server-certs'];

local initContainers = [
  madkub.madkubInitContainer(certDirs),
  madkub.permissionSetterInitContainer,
];


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
  {
    name: 'RANDVAL',
    value: '45',
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
  {
    containerPort: 7022,
    name: 'http1',
  },
];

if configs.kingdom == 'mvp' then {
  apiVersion: 'apps/v1beta1',
  kind: 'StatefulSet',
  metadata: {
    name: 'consul-internal-server',
    namespace: topologysvcNamespace,
    labels: {} + configs.pcnEnableLabel,
  },
  spec: {
    serviceName: 'consul-internal-headless',
    podManagementPolicy: 'Parallel',
    updateStrategy: {
        type: 'RollingUpdate',
    },
    volumeClaimTemplates: [
            {
                metadata: {
                   name: "consul-data-volume",
                   annotations:
                   {
                       "volume.beta.kubernetes.io/storage-class": "faster",
                   },
                },
                spec: {
                   accessModes: [
                      "ReadWriteOnce",
                   ],
                   resources: {
                      requests: {
                         storage: "2Gi",
                      },
                   },
                },
            },
        ],
    replicas: 3,
    selector: {
      matchLabels: {
        app: 'consul-internal-server',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'consul-internal-server',
        },
        annotations: {
          'madkub.sam.sfdc.net/allcerts':
          std.manifestJsonEx(
          {
              certreqs:
              [
                  certReq
                  for certReq in madkub.madkubTopologySvcCertsAnnotation(certDirs).certreqs
              ],
          }, ' '
          ),
        },
      },
      spec: {
        initContainers: initContainers,
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
            name: 'consul-internal',
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
              '-http-port=7022',
              '-disable-host-node-id',
              '-retry-join=consul-internal-server-0.consul-internal-headless.$(NAMESPACE).svc',
              '-retry-join=consul-internal-server-1.consul-internal-headless.$(NAMESPACE).svc',
              '-retry-join=consul-internal-server-2.consul-internal-headless.$(NAMESPACE).svc',
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
                  '/bin/sh',
                  '-ec',
                  'curl "http://$POD_IP:7022/v1/status/leader" 2> /dev/null | grep -E \'".+"\'',
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
            volumeMounts: [
            {
              name: "consul-data-volume",
              mountPath: "/consul/data",
            },
            ] + madkub.madkubTopologySvcCertVolumeMounts(certDirs),
          },
          serviceMesh.service_discovery_container("topology-client"),
          madkub.madkubRefreshContainer(certDirs),
        ],
        volumes+: [
            configs.maddog_cert_volume,
        ] + madkub.madkubTopologySvcCertVolumes(certDirs)
                              + madkub.madkubTopologySvcMadkubVolumes(),
      },
    },
  },
} else 'SKIP'
