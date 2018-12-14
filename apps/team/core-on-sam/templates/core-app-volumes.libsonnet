local coreAppVolumes = [
  {
    name: 'envoy-config-volume',
    emptyDir: {},
  },
  {
    name: 'coreapp-config-volume',
    emptyDir: {},
  },
  {
    name: 'tls-client-cert',
    maddogCert: {
      type: 'client',
    },
  },
  {
    name: 'tls-server-cert',
    maddogCert: {
      type: 'server',
    },
  },
  {
    name: 'log-volume-sfdc',
    hostPath: {
      path: '/data/logs/sfdc',
    },
  },
  {
    name: 'log-volume-jvm',
    hostPath: {
      path: '/data/logs/jvm',
    },
  },
];

// Export the volumes array
coreAppVolumes
