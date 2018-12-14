{
  name: $.functionName,
  identity: {
    serviceName: "sfproxy",
    pod: $.env.instanceName,
  },
  count: 1,
  containers: [
    {
      name: "sfproxy-envoy",
      image: $.env.sfProxyImage,
      env: [
        {
          name: "ENVOY_DEBUG_OPTIONS",
          value: "--log-path /home/sfdc-sherpa/envoy.log",
        },
        {
          name: "SFDC_ENVIRONMENT",
          value: $.env.sfProxySfdcEnvironment($.env),
        },
      ],
      args: [
        "--template=/home/sfdc-sherpa/sfproxy/config/core-on-sam/sfproxy-rds.yaml.template",
        "--switchboard=" + $.env.switchboard,
        "--log-level=trace",
      ],
      ports: [
        {
          containerPort: 2525,
        },
        {
          containerPort: 12060,
        },
        {
          containerPort: 15373,
        },
      ],
      livenessProbe: {
        exec: {
          command: [
            "./bin/is-alive",
          ],
        },
        initialDelaySeconds: 20,
        periodSeconds: 5,
      },
      readinessProbe: {
        exec: {
          command: [
            "./bin/is-ready",
          ],
        },
        initialDelaySeconds: 15,
        periodSeconds: 5,
      },
      volumeMounts: [
        {
          name: "tls-client-cert",
          mountPath: "/client-certs",
        },
        {
          name: "tls-server-cert",
          mountPath: "/server-certs",
        },
      ],
    },
  ],
  volumes: [
    {
      name: "tls-client-cert",
      maddogCert: {
        type: "client",
      },
    },
    {
      name: "tls-server-cert",
      maddogCert: {
        type: "server",
        lbnames: [
          $.lbName,
        ],
      },
    },
  ],
}
