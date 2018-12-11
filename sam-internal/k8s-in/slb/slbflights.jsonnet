local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    ipvsTurnDownOnSIGTERM: (slbimages.phaseNum <= 1),
    ifaceProcessorAddIfaceIfIPVSHost: (slbimages.phaseNum <= 1),
    antiDDOS: (slbimages.phaseNum <= 3),
    fredEnabled: (configs.estate == "prd-sdc"),
    // Gigantor celery logs are spamming the root disk partition (`/`) in fra. The root partition only has 100 GB, and is critical for
    // services to function. Enabling this script in fra to clean those logs.
    cleanupGigantorLogs: (configs.estate == "fra-sam"),
    dhParamsConfigMapEnabled: (slbimages.hypersdn_build >= 1401),
    nginxTlsConfigEnabled: (slbimages.phaseNum <= 4),
    georgeEnabled: (configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1380),
}
