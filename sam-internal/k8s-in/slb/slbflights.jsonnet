local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    fredEnabled: (slbimages.phaseNum <= 2),
    georgeEnabled: (slbimages.phaseNum <= 2),
    nginxAccesslogsEnabled: (configs.estate == "prd-sdc"),
    portalKubeConfigEnabled: (slbimages.hypersdn_build >= 1431),
    nginxLogsRefactor: (if slbimages.slbnginx_build >= 61 then true else false),
    slaRequiresPreciseHealthProbesEnabled: slbimages.phaseNum <= 2,
    statusVipEnabled: (slbimages.phaseNum <= 3 || slbimages.hypersdn_build > 1431),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 1),
}
