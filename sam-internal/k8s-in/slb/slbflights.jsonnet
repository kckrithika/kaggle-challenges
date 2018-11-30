local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    useSlbScriptsInImage: (slbimages.hypersdn_build >= 1390),
    ipvsTurnDownOnSIGTERM: (slbimages.phaseNum <= 1),
    ifaceProcessorAddIfaceIfIPVSHost: (slbimages.phaseNum <= 1),
    antiDDOS: (slbimages.phaseNum <= 2),
    fredEnabled: (configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1380),
}
