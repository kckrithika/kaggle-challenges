{
  New(env): {
    name: "caas-redis-announcer",
    image: "tnrp/caas/caas-redis:2.4.5-0000009-14383588",
    command: [
      "/opt/caas/redis/announcer-startup.sh",
    ],
    args: [
      "--redisPort=12046",
      "--cluster.name=caas-cluster-casam-sp2",
      "--logDir=/home/caas/logs",
      "--pathPrefix=/mist61/prd/sp2",
    ],
    livenessProbe: {
      initialDelaySeconds: 5,
      exec: {
        command: [
          "/opt/caas/redis/is-alive.sh",
        ],
      },
    },
    env: [
      {
        name: "SFDC_ENVIRONMENT",
        value: "mist61",
      },
    ],
    resources: {
      limits: {
        memory: "200M",
      },
      requests: {
        memory: "200M",
      },
    },
    volumeMounts: [
      {
        mountPath: "/home/caas/logs",
        name: "logvol",
      },
      {
        mountPath: "/var/secrets",
        name: "secretvol",
        readOnly: true,
      },
    ],
  },
}
