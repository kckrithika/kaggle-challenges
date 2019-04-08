local configs = import 'config.jsonnet';
local utils = import 'util_functions.jsonnet';
local images = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };

{

  // Service mesh volumes
  sherpa_volume_mounts():: [
    {
      mountPath: '/client-certs',
      name: 'tls-client-cert',
    },
    {
      mountPath: '/server-certs',
      name: 'tls-server-cert',
    },
  ],

  // Service mesh container definition
  service_discovery_container():: {
    name: 'sherpa',
    image: images.sherpa,
    args+: [] +
           if configs.estate == 'gsf-core-devmvp-sam2-sam' then ['--switchboard=switchboard.service-mesh.svc:15001']
           else if configs.estate == 'gsf-core-devmvp-sam2-samtest' then ['--switchboard=switchboard-test.service-mesh.svc.sam.core.test.us-central1.gcp.sfdc.net:15001']
           else [],
    env: [
      {
        name: 'SFDC_ENVIRONMENT',
        value: 'mesh',
      },
      {
        name: 'SETTINGS_SERVICENAME',
        value: 'consul-server',
      },
      {
        name: 'FUNCTION_NAMESPACE',
        valueFrom: {
          fieldRef: {
            apiVersion: 'v1',
            fieldPath: 'metadata.namespace',
          },
        },
      },
      {
        name: 'FUNCTION_INSTANCE_NAME',
        valueFrom: {
          fieldRef: {
            apiVersion: 'v1',
            fieldPath: 'metadata.name',
          },
        },
      },
      {
        name: 'FUNCTION_INSTANCE_IP',
        valueFrom: {
          fieldRef: {
            apiVersion: 'v1',
            fieldPath: 'status.podIP',
          },
        },
      },
      {
        name: 'FUNCTION',
        value: 'consul-server',
      },
      {
        name: 'KINGDOM',
        value: configs.kingdom,
      },
      {
        name: 'ESTATE',
        value: configs.estate,
      },
      {
        name: 'SUPERPOD',
        value: '-',
      },
      {
        name: 'SETTINGS_SUPERPOD',
        value: '-',
      },
      {
        name: 'SETTINGS_PATH',
        value: 'mesh.-.mvp.-.consul-server',
      },
      {
        name: 'SFDC_SETTINGS_PATH',
        value: 'mesh.-.mvp.-.consul-server',
      },
      {
        name: 'SFDC_METRICS_SERVICE_HOST',
        value: 'funnel.ajnalocal1.vip.core.test.us-central1.gcp.sfdc.net',
      },
      {
        name: 'SFDC_METRICS_SERVICE_PORT',
        value: '443',
      },
    ],
    resources: {
      requests: {
        memory: '1Gi',
        cpu: '1',
      },
      limits: {
        memory: '1Gi',
        cpu: '1',
      },
    },
    ports: [
      {
        name: 'http-tls-in',
        containerPort: 7442,
      },
      {
        name: 'sherpa-adm',
        containerPort: 15373,
      },
    ],
    livenessProbe: {
      exec: {
        command: [
          './bin/is-alive',
        ],
      },
      initialDelaySeconds: 20,
      periodSeconds: 5,
    },
    readinessProbe: {
      exec: {
        command: [
          './bin/is-ready',
        ],
      },
      initialDelaySeconds: 15,
      periodSeconds: 5,
    },
    volumeMounts: $.sherpa_volume_mounts(),
  },

}
