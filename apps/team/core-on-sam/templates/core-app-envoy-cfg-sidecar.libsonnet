{
  New(region, instanceName, env): {
    name: 'envoy-sidecar-config',
    image: env.envoyConfigSidecarImage,
    env: [
      {
        name: 'CONFIG_DIR',
        value: '/home/sfdc-sherpa/sherpa-envoy-config-volume',
      },
    ],
    volumeMounts: [
      {
        name: 'envoy-config-volume',
        mountPath: '/home/sfdc-sherpa/sherpa-envoy-config-volume',
      },
    ],
    livenessProbe: {
      exec: {
        command: [
          'cat',
          '/tmp/live',
        ],
      },
      initialDelaySeconds: 10,
      periodSeconds: 5,
    },
    readinessProbe: {
      exec: {
        command: [
          'cat',
          '/tmp/ready',
        ],
      },
      initialDelaySeconds: 10,
      periodSeconds: 5,
    },
  },
}
