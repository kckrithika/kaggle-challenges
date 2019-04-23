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

local ports = [
  {
    containerPort: 8080,
    name: 'server',
  },
];

if configs.kingdom == 'mvp' then {
    apiVersion: 'apps/v1beta1',
    kind: 'Deployment',
    metadata: {
      name: 'topology-client',
      namespace: topologysvcNamespace,
      labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'topology-client',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'topology-client',
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
            securityContext: {
              fsGroup: 7447,
              runAsNonRoot: true,
              runAsUser: 7447,
            },
            containers: [
              {
                name: 'topology-client',
                image: topologysvcimages.topologyClient,
                ports: ports,
                securityContext: {
                  runAsNonRoot: true,
                  runAsUser: 7447,
                },
                volumeMounts: [
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
