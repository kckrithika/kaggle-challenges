local sequencerMain = import "sequencer-main.libsonnet";

{
  name: $.functionName,
  identity: {
    serviceName: "sequencer",
    pod: $.env.instanceName,
  },
  count: 1,
  terminationGracePeriodSeconds: 500,
  progressDeadlineSeconds: 300,
  volumes: [
    {
      name: "cert",
      maddogCert: {
        type: "client",
      },
    },
    {
      name: "secretvol",
      k4aSecret: {
        secretName: "sequencer-gus",
      },
    },
    {
      name: "kaiju-secret-vol",
      k4aSecret: {
        secretName: "sequencer-kaiju",
      },
    },
  ],
  containers: [
    sequencerMain.New($.env.region, $.env.instanceName, $.env),
  ],
}
