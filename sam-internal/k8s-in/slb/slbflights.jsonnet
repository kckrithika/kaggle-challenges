local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 7 then true else false),
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    nginxSlbVolumeMount: (slbimages.slbnginx_build >= 50),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    removeCleanupDs: (slbimages.hypersdn_build >= 1347),
    newAccessLogFormat: (slbimages.hypersdn_build >= 1347),
    syncHealthConfigEnabled: (slbimages.hypersdn_build >= 1372),
    nginxReadinessProbeEnabled: (slbimages.hypersdn_build >= 1355),
    supportedProxiesEnabled: (slbimages.hypersdn_build > 1355),
    proxyconfig_volume: (if $.supportedProxiesEnabled then slbconfigs.proxyconfig_volume else {}),
    reduceNginxMinReady: (slbimages.hypersdn_build >= 1355),
    tuneIfaceSentinelExpiration: (slbimages.hypersdn_build > 1355),
    kernLogCleanup: (slbimages.phaseNum <= 2),
    cleanupHostNet: (slbimages.phaseNum <= 1),
}
