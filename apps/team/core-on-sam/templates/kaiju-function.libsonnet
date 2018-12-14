local kaijuMain = import "kaiju-main.libsonnet";

{
  name: $.functionName,
  count: 1,
  terminationGracePeriodSeconds: 500,
  progressDeadlineSeconds: 300,
  volumes: {
    name: "cert",
    maddogCert: {
      type: "client",
    },
  },
  containers: [
    kaijuMain.New($.env),
  ],
}
