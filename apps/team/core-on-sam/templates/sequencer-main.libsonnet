{
  New(region, instanceName, env): {
    name: "sequencer",
    image: env.sequencerImage,
    env: [
      {
        name: "DEPLOY_ENV",
        value: "alpha",
      },
      {
        name: "CYAN",
        value: env.sfProxyEP(env),
      },
      {
        name: "CURL_GLOBAL_OPTS",
        value: "-k",
      },
      {
        name: "K4A",
        value: "have_to_get_this",
      },
      {
        name: "ENABLE_DB_SCHEMA_UPGRADE",
        value: 1,
      },
      {
        name: "SET_DEFAULT_ORACLE_EDITION",
        value: 1,
      },
      {
        name: "OLD_DWARF",
        value: "sneezy",
      },
      {
        name: "CURRENT_RELEASE_VERSION",
        value: env.currentAppColor(env),
      },
      {
        name: "NEW_RELEASE_VERSION",
        value: env.casamAppColor,
      },
      {
        name: "READY_SERVER_COUNT",
        value: env.coreAppReplicaCount,
      },
      {
        name: "DB_SID",
        value: env.dbSID,
      },
      {
        name: "LOCK_DWARF",
        value: 1,
      },
      {
        name: "TRIGGER_CAFFEINE",
        value: 1,
      },
      {
        name: "UNLOCK_DWARF",
        value: 1,
      },
      {
        name: "SNOWWHITE_PWD",
        value: "rotate",
      },
      {
        name: "MADDOG_CLIENT",
        value: "/certs",
      },
      {
        name: "CASAM_SETTINGS_PATH",
        value: env.envName + "." + env.subEnvName + "." + region + "." + instanceName + ".sequencer",
      },
      {
        name: "CASAM_SUPERPOD",
        value: "sp2",
      },
    ],
    livenessProbe: {
      httpGet: {
        path: "/login",
        port: 12062,
      },
      initialDelaySeconds: 60,
      periodSeconds: 1,
      failureThreshold: 10,
    },
    readinessProbe: {
      httpGet: {
        path: "/login",
        port: 12062,
      },
      initialDelaySeconds: 60,
      periodSeconds: 1,
      failureThreshold: 10,
    },
    ports: [
      {
        containerPort: 12062,
      },
    ],
    volumeMounts: [
      {
        name: "cert",
        mountPath: "/certs",
      },
      {
        name: "secretvol",
        mountPath: "/secrets/",
        readOnly: true,
      },
      {
        name: "kaiju-secret-vol",
        mountPath: "/kaiju-secrets/",
        readOnly: true,
      },
    ],
  },
}
