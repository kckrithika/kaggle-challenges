{
  New(region, instanceName, env): {
    name: 'config-sidecar',
    image: env.configSidecarImage,
    env: [
      {
        name: 'CASAM_SETTINGS_PATH',
        value: env.envName + "." + env.subEnvName + "." + region + "." + instanceName + ".app",
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
    volumeMounts: [
      {
        name: 'coreapp-config-volume',
        mountPath: '/home/sfdc/config_override',
      },
    ],
  },
}
