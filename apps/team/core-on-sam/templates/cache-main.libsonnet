{
  New(env): {
    name: "caas-redis",
    image: "tnrp/caas/caas-redis:3.2.10-0000019-15183614",
    resources: {
      limits: {
        memory: "8292M",
      },
      requests: {
        memory: "8292M",
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
    args: [
      "--port=12046",
      "--maxMemoryMB=5120",
      "--logDir=/home/caas/logs",
    ],
    livenessProbe: {
      exec: {
        command: [
          "/opt/caas/redis/redis-livenessprobe.py",
          "--port=12046",
        ],
      },
      initialDelaySeconds: 15,
      timeoutSeconds: 10,
    },
    env: [
      {
        name: "SFDC_ENVIRONMENT",
        value: "mist61",
      },
    ],
    ports: [
      {
        containerPort: 12046,
        name: "caas-cluster",
      },
    ],
  },
}
