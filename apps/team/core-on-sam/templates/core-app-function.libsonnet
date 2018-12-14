local coreAppConfigContainer = import "core-app-cfg-sidecar.libsonnet";
local coreAppEnvoyConfigSidecar = import "core-app-envoy-cfg-sidecar.libsonnet";
local coreAppEnvoySidecar = import "core-app-envoy-sidecar.libsonnet";
local coreAppContainer = import "core-app-main.libsonnet";
local coreAppVolumes = import "core-app-volumes.libsonnet";

{
  name: $.functionName,
  count: $.env.coreAppReplicaCount,
  volumes: coreAppVolumes,
  identity: {
    serviceName: "app",
    pod: $.env.instanceName,
  },
  terminationGracePeriodSeconds: 500,
  progressDeadlineSeconds: 300,
  strategy: {
    type: 'RollingUpdate',
    rollingUpdate: {
      maxSurge: '200%',
      maxUnavailable: 0,
    },
  },
  containers: [
    coreAppContainer.New($.env.region, $.env.instanceName, $.env),
    coreAppConfigContainer.New($.env.region, $.env.instanceName, $.env),
    coreAppEnvoySidecar.New($.env.region, $.env.instanceName, $.env),
    coreAppEnvoyConfigSidecar.New($.env.region, $.env.instanceName, $.env),
  ],
}
