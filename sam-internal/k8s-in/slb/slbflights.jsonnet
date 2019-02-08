local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    nginxAccesslogsEnabled: (slbimages.hyperslb_build >= 2053),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),
    portalSfdcHostsMountEnabled: (slbimages.phaseNum <= 4),
    artifactoryBootstrapEnabled: (slbimages.hyperslb_build >= 2046),
    kernelVersionCheckerEnabled: (slbimages.hyperslb_build >= 2053),
    nginxStreamlogsEnabled: (slbimages.phaseNum <= 1),
    fredVipFix: (slbimages.hyperslb_build >= 2055),
}
