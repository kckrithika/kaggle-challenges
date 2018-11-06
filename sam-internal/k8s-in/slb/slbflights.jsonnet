local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 7 then true else false),
    nginxPodFloat: (slbimages.phaseNum <= 5),
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    nginxSlbVolumeMount: (slbimages.slbnginx_build >= 50),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    removeDeprecatedNginxParameters: (slbimages.hypersdn_build >= 1340),
    nginxBaseTemplateEnabled: (slbimages.hypersdn_build >= 1340),
    removeCleanupDs: (slbimages.phaseNum <= 3),
    newAccessLogFormat: (slbimages.hypersdn_build >= 1347),
    aclEnabled: (slbimages.phaseNum <= 2),
    syncHealthConfigEnabled: (slbimages.phaseNum <= 1),
    vipAclEnabled: (slbimages.phaseNum <= 2),
}
