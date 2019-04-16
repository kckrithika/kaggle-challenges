local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local madkub = (import 'topology-svc-madkub-san-test.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

local certDirs = ['cert1', 'client-certs', 'server-certs'];

local initContainers = [
  madkub.madkubInitContainer(certDirs),
  madkub.permissionSetterInitContainer,
];

local ports = [
  {
    containerPort: 9090,
    name: 'server',
  },
];

if configs.kingdom == 'mvp' then {
    apiVersion: 'apps/v1beta1',
    kind: 'Deployment',  #would it be deployment here?
    metadata: {
      name: 'samhello-ns1',
      namespace: topologysvcNamespace,
      labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'samhello-ns1',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'samhello-ns1',
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
                name: 'samhello',
                image: topologysvcimages.samhello,
                ports: ports,
                securityContext: {
                  runAsNonRoot: true,
                  runAsUser: 7447,
                },
                volumeMounts: [
                ] + madkub.madkubTopologySvcCertVolumeMounts(certDirs),
              },
              # service mesh is not required.
              #topologysvcutils.service_discovery_container(),
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
