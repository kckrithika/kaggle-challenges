local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    fredEnabled: (slbimages.hypersdn_build >= 1446),
    georgeEnabled: (slbimages.hypersdn_build >= 1446),
    nginxAccesslogsEnabled: (configs.estate == "prd-sdc"),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),
    portalSfdcHostsMountEnabled: (slbimages.phaseNum <= 3),
    artifactoryBootstrapEnabled: (slbimages.hypersdn_build >= 2046),
    kernelVersionCheckerEnabled: (slbimages.hypersdn_build >= 2053),
}
