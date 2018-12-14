{
  New(region, instanceName, env): {
    name: 'envoy-sidecar',
    image: env.envoySidecarImage,
    env: [
      {
        name: 'SFDC_ENVIRONMENT',
        value: 'envoy-sidecar',
      },
    ],
    args: [
      '--template',
      '/cyan-config/tls-terminator-config.yaml.template',
    ],
    ports: [
      {
        containerPort: 13065,
      },
      {
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
    volumeMounts: [
      {
        name: 'envoy-config-volume',
        mountPath: '/cyan-config',
      },
      {
        name: 'tls-client-cert',
        mountPath: '/certs/cert-client',
      },
      {
        name: 'tls-server-cert',
        mountPath: '/certs/cert-server',
      },
    ],
  },
}
