local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    hsmDeleteLimitOverride: (slbimages.hypersdn_build <= 1379),
    cleanupHostNet: (slbimages.phaseNum <= 2),
    ipvsTurnDownOnSIGTERM: (slbimages.phaseNum <= 1),
    ifaceProcessorAddIfaceIfIPVSHost: (slbimages.phaseNum <= 1),
    ipvsHealthCheckerCustomUserAgent: (slbimages.hypersdn_build >= 1379),
}
