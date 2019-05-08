// StatefulSet to run the actual Consul server cluster.
local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local madkub = (import 'topology-svc-madkub.jsonnet') + { templateFilename:: std.thisFile };
local serviceMesh = (import 'topology-svc-sherpa.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

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
    name: 'CONSUL_CACERT',
    value: '/config/cacerts.pem',
  },
  {
    name: 'CONSUL_CLIENT_CERT',
    value: '/config/peer.pem',
  },
  {
    name: 'CONSUL_CLIENT_KEY',
    value: '/config/peer-key.pem',
  },
  {
    name: 'Rand-val',
    value: '50',
  },
];

local topologyEnv = [
  {
    name: "JVM_ARGS",
    value: "-Dspring.profiles.active=gcp -Dserver.port=7022",
  },
];

local ports = [
  {
    containerPort: 8500,
    name: 'http',
  },
  {
    containerPort: 8501,
    name: 'https',
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

local sports = [
  {
    containerPort: 8080,
    name: 'scone-server',
  },
  {
    containerPort: 8081,
    name: 'mgmt-server',
  },
  {
    containerPort: 15372,
    name: 'scone-mgmt',
  },
  {
    containerPort: 7022,
    name: 'scone-http',
  },
];

if configs.kingdom == 'mvp' then {
  apiVersion: 'apps/v1beta1',
  kind: 'StatefulSet',
  metadata: {
    name: 'consul-client-test-server',
    namespace: topologysvcNamespace,
    labels: {} + configs.pcnEnableLabel,
  },
  spec: {
    serviceName: 'consul-client-test-headless',
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
                         storage: "1Gi",
                      },
                   },
                },
            },
        ],
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'consul-client-test-server',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'consul-client-test-server',
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
            name: 'topology-client',
            image: topologysvcimages.topologysvclocal,
            ports: sports,
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 7447,
            },
            args: [
                  "--server.port=7022",
            ],
            env: topologyEnv,
            volumeMounts: [
            ] + madkub.madkubTopologySvcCertVolumeMounts(certDirs),
          },
          {
            name: 'consul-client-test',
            image: topologysvcimages.consulgcp,
            args: [
              'agent',
              '-advertise=$(POD_IP)',
              '-bind=0.0.0.0',
              '-client=0.0.0.0',
              '-datacenter=gcp-uscentral1',
              '-data-dir=/consul/data',
              '-domain=cluster.local',
              '-config-dir=/config/consulclientencrypt.json',
              '-disable-host-node-id',
              '-retry-join=consul-test-server-0.consul-test-headless.$(NAMESPACE).svc',
              '-retry-join=consul-test-server-1.consul-test-headless.$(NAMESPACE).svc',
              '-retry-join=consul-test-server-2.consul-test-headless.$(NAMESPACE).svc',
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
          serviceMesh.service_discovery_container("topology-svc"),
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
