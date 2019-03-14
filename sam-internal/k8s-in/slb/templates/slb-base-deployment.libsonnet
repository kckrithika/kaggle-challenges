{
  dirSuffix:: "",
  local configs = import "config.jsonnet",
  local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbports = import "slbports.jsonnet",
  local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },

  slbBaseDeployment(
    name,
    replicas=2,
    affinity,
    beforeSharedContainers,
    afterSharedContainers=[],
    supportedProxies=[],
    deleteLimitOverride=0,
  ):: configs.deploymentBase("slb") {

    metadata: {
      labels: {
        name: name,
      } + configs.ownerLabel.slb,
      name: name,
      namespace: "sam-system",
    },
    spec+: {
      revisionHistoryLimit: 2,
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            name: name,
          } + configs.ownerLabel.slb,
          namespace: "sam-system",
        },
        spec: {
                affinity: affinity,
                volumes: std.prune([
                  slbconfigs.slb_volume,
                  slbconfigs.logs_volume,
                  slbconfigs.slb_config_volume,
                  slbconfigs.cleanup_logs_volume,
                  configs.sfdchosts_volume,
                  configs.kube_config_volume,
                  configs.maddog_cert_volume,
                  configs.cert_volume,
                  slbconfigs.sbin_volume,
                  slbconfigs.proxyconfig_volume,
                ]),
                containers: beforeSharedContainers + [
                  slbshared.slbConfigProcessor(
                    slbports.slb.slbConfigProcessorLivenessProbePort,
                    supportedProxies=supportedProxies
),
                  slbshared.slbCleanupConfig,
                  slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                  slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiPort, true, deleteLimitOverride=deleteLimitOverride),
                  slbshared.slbLogCleanup,
                  slbshared.slbManifestWatcher(
                    supportedProxies=supportedProxies, deleteLimitOverride=deleteLimitOverride
),
                ] + afterSharedContainers,
              } + slbconfigs.getDnsPolicy(),
      },
      strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
          maxUnavailable: (if slbflights.permitMoreUnavailable && replicas >= 8 then "25%" else 1),
          maxSurge: 0,
        },
      },
      minReadySeconds: 60,
    },
  },
}
