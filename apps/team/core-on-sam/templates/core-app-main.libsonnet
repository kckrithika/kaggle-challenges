{
  New(region, instanceName, env): {
    name: "coreapp",
    image: env.coreAppImage,
    env: [
      {
        name: 'DB_SID',
        value: env.dbSID,
      },
      {
        name: 'DB_INSTANCE_NAME',
        value: env.dbInstanceName,
      },
      {
        name: 'DB_USER',
        value: env.dbUser,
      },
      {
        name: 'DB_PASSWORD',
        value: 'rotate',
      },
      {
        name: 'DB_STATS_USER',
        value: env.dbStatsUser,
      },
      {
        name: 'DB_STATS_PASSWORD',
        value: 'rotate',
      },
      {
        name: 'DB_CONN_NUM',
        value: env.dbConnectionCount,
      },
      {
        name: 'PLSQL_UPDATE_RUNSTATS',
        value: false,
      },
      {
        name: 'SERVER_ID',
        value: 'x',
      },
      {
        name: 'IP_DB',
        value: env.ipDB,
      },
      {
        name: 'IP_MNDS1',
        value: '127.0.0.1',
      },
      {
        name: 'OFFLINE',
        value: true,
      },
      {
        name: 'PUBLIC_PORT',
        value: 8443,
      },
      {
        name: 'PUBLIC_PORT_IS_SECURE',
        value: true,
      },
      {
        name: 'PUBLIC_HOST_NAME',
        value: env.publicHostName(env),
      },
      {
        name: 'SFPROXY_VIP',
        value: env.publicEP(env),
      },
      {
        name: 'HTTP_PORT',
        value: 8085,
      },
      {
        name: 'SPORT',
        value: 8443,
      },
      {
        name: 'S2PORT',
        value: 12098,
      },
      {
        name: 'DISABLE_AUTH_RELEASE_CHECK',
        value: true,
      },
      {
        name: 'CASAM_APP_COLOR',
        value: env.casamAppColor,
      },
      {
        name: 'SD_PORT_OVERRIDE',
        value: 13065,
      },
      {
        name: 'CASAM_SETTINGS_PATH',
        value: env.envName + "." + env.subEnvName + "." + region + "." + instanceName + ".app",
      },
      {
        name: 'CLUSTER_NAME',
        value: instanceName,
      },
      {
        name: 'DEPLOYMENT',
        value: 'B',
      },
      {
        name: 'USE_CONFIG_SIDECAR',
        value: 1,
      },
      {
        name: 'CASAM_HOST_NAME',
        valueFrom: {
          fieldRef: {
            fieldPath: 'spec.nodeName',
          },
        },
      },
    ],
    livenessProbe: {
      exec: {
        command: [
          'echo',
          'HEALTHY',
        ],
      },
      initialDelaySeconds: 480,
      periodSeconds: 1,
    },
    readinessProbe: {
      httpGet: {
        path: '/ping.jsp',
        port: 8085,
      },
      initialDelaySeconds: 120,
      periodSeconds: 1,
      failureThreshold: 10,
    },
    ports: [
      {
        containerPort: 8998,
      },
      {
        containerPort: 8085,
      },
      {
        containerPort: 11211,
      },
      {
        containerPort: 12098,
      },
      {
        containerPort: 8443,
      },
    ],
    volumeMounts: [
      {
        name: 'log-volume-sfdc',
        mountPath: '/home/sfdc/logs/sfdc',
      },
      {
        name: 'log-volume-jvm',
        mountPath: '/home/sfdc/logs/jvm',
      },
      {
        name: 'tls-client-cert',
        mountPath: '/etc/pki_service',
      },
      {
        name: 'coreapp-config-volume',
        mountPath: '/home/sfdc/config_override',
      },
    ],
  },
}
