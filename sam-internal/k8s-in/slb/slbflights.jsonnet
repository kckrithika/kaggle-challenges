local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),
    nginxStreamlogsEnabled: (slbimages.phaseNum <= 4 && slbimages.slbnginx_build >= 114 && slbimages.hsmnginx_build >= 114),
    removeRequiresHealthProbeFlag: (slbimages.hyperslb_build > 2061),
    enableOnlyRunningStateProxy: (configs.estate == "prd-sdc"),
    tempDisableNginxAccesslogs: (configs.estate == "prd-sdc"),
}
