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
    ipvsConnTabBits: (if slbimages.hypersdn_build >= 1423 then 20 else 0),
    ipvsInstallerPackage: (if slbimages.hypersdn_build >= 1425 then "20190114" else "20180910"),
    nginxAccesslogsEnabled: (configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1425),
    portalKubeConfigEnabled: (slbimages.hypersdn_build >= 1431),
}
