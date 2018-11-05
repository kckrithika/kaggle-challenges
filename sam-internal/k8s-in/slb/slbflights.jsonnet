local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 7 then true else false),
    nginxPodFloat: (slbimages.phaseNum <= 4),
    envoyProxyEnabled: (slbimages.phaseNum <= 1),
    roleEnabled: (slbimages.phaseNum <= 1),
    nginxSlbVolumeMount: (slbimages.slbnginx_build >= 50),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    removeDeprecatedNginxParameters: (slbimages.hypersdn_build >= 1340),
    nginxBaseTemplateEnabled: (slbimages.hypersdn_build >= 1340),
    removeCleanupDs: (slbimages.hypersdn_build >= 1344),
    newAccessLogFormat: (slbimages.phaseNum <= 1),
    aclEnabled: (slbimages.phaseNum <= 1),
}
