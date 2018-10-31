{
  dirSuffix:: "",
  local configs = import "config.jsonnet",
  local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbports = import "slbports.jsonnet",

  slbBaseProxyDeployment(
    proxyName,
    replicas=2,
    affinity,
    beforeSharedContainers,
    afterSharedContainers
  ):: configs.deploymentBase("slb") {

    metadata: {
      labels: {
        name: proxyName,
      } + configs.ownerLabel.slb,
      name: proxyName,
      namespace: "sam-system",
    },
    spec+: {
      revisionHistoryLimit: 2,
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            name: proxyName,
          } + configs.ownerLabel.slb,
          namespace: "sam-system",
        },
        spec: {
                affinity: affinity,
                volumes: configs.filter_empty([
                  slbconfigs.slb_volume,
                  slbconfigs.logs_volume,
                  slbconfigs.slb_config_volume,
                  slbconfigs.cleanup_logs_volume,
                  configs.sfdchosts_volume,
                  configs.kube_config_volume,
                  slbconfigs.sbin_volume,
                ]),
                containers: beforeSharedContainers + [
                  slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                  slbshared.slbCleanupConfig,
                  slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                  slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiPort, true),
                  slbshared.slbLogCleanup,
                  slbshared.slbManifestWatcher(),
                ] + afterSharedContainers,
              } + slbconfigs.getDnsPolicy(),
      },
      strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
          maxUnavailable: 1,
          maxSurge: 0,
        },
      },
      minReadySeconds: 60,
    },
  },
}
