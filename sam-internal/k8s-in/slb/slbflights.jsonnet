local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),
    enableOnlyRunningStateProxy: (slbimages.hyperslb_build >= 2066),
    enableNginxAccesslogs: (slbimages.hyperslb_build >= 2068),
    removeDeprecatedIpvsProcessorFlags: (slbimages.hyperslb_build >= 2066),
    slbCleanupUnknownPods: (slbimages.hyperslb_build >= 2067),
    useKubeDnsForPortal: (slbimages.phaseNum <= 2),
    internalIpRange: (if slbimages.phaseNum <= 2 then ["--iprange.InternalIpRange=%s" % [slbconfigs.perCluster.internalIpRange[configs.estate]]] else []),
    conntrackMetrics: (slbimages.hyperslb_build >= 2069),
    slbUpstreamReporterEnabled: (if slbimages.phaseNum <= 3 && slbimages.hyperslb_build >= 2071 then true else false),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),
}
