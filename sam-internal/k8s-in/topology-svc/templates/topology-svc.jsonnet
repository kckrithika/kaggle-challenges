local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local madkub = (import 'topology-svc-madkub.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

local certDirs = ['cert1', 'client-certs', 'server-certs'];

local initContainers = [
  madkub.madkubInitContainer(certDirs),
  madkub.permissionSetterInitContainer,
];

local ports = [
  {
    containerPort: 8080,  #add port 7022 and 7422 after mesh integration.
    name: 'scone-http',
  },
  {
    containerPort: 15372,
    name: 'scone-mgmt',
  },
];

local topologyEnv = [
  {
    name: "JVM_ARGS",
    value: "-Dspring.profiles.active=gcp",  #add -Dserver.port=7022 after mesh integration
  },
];

if configs.kingdom == 'mvp' then {
    apiVersion: 'apps/v1beta1',
    kind: 'Deployment',
    metadata: {
      name: 'topology-svc',
      namespace: topologysvcNamespace,
      labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        replicas: 3,
        selector: {
          matchLabels: {
            app: 'topology-svc',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'topology-svc',
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
                name: 'topology-svc-service',
                image: topologysvcimages.topologysvc,
                ports: ports,
                securityContext: {
                  runAsNonRoot: true,
                  runAsUser: 7447,
                },
                #add args after mesh integration.
                #args: [
                   # "--server.port=7022",
                #],
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
