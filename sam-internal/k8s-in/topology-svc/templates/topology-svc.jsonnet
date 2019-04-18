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
    containerPort: 7022,
    name: 'scone-http',
  },
  {
    containerPort: 7442,
    name: 'scone-http1-tls',
  },
  {
    containerPort: 15372,
    name: 'scone-mgmt',
  },
];

local topologyEnv = [
  {
    name: "JVM_ARGS",
    value: "-Dspring.profiles.active=gcp -Dserver.port=7022",
  },
];

if configs.kingdom == 'mvp' then {
    apiVersion: 'apps/v1beta1',
    kind: 'Deployment',
    metadata: {
      name: 'topology-svc-internal',
      namespace: topologysvcNamespace,
      labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        replicas: 3,
        selector: {
          matchLabels: {
            app: 'topology-svc-internal',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'topology-svc-internal',
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
                name: 'topology-svc-internal-service',
                image: topologysvcimages.topologysvc,
                ports: ports,
                securityContext: {
                  runAsNonRoot: true,
                  runAsUser: 7447,
                },
                args: [
                  "--server.port=7022",
                ],
                env: topologyEnv,
                readinessProbe: {
                  failureThreshold: 3,
                  initialDelaySeconds: 30,
                  periodSeconds: 10,
                  successThreshold: 1,
                  timeoutSeconds: 5,
                  httpGet: {
                    path: "/manage/health",
                    port: 15372,
                    scheme: "HTTP",
                  },
                },
                volumeMounts: [
                ] + madkub.madkubTopologySvcCertVolumeMounts(certDirs),
              },
              serviceMesh.service_discovery_container("topology-svc-internal"),
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
