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
    useKubeDnsForPortal: (slbimages.phaseNum <= 3),
    internalIpRange: (if slbimages.phaseNum <= 4 then ["--iprange.InternalIpRange=%s" % [slbconfigs.perCluster.internalIpRange[configs.estate]]] else []),
    slbUpstreamReporterEnabled: (if (slbimages.phaseNum <= 3 && slbimages.hyperslb_build >= 2071) || slbimages.hyperslb_build >= 2072 then true else false),
    slbTCPdumpEnabled: (slbimages.phaseNum <= 1),
    nginAccesslogsRunInSlbEstate: (slbimages.hyperslb_build >= 2072),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),
    # Only set to true if hyperslb >= 2088
    useHttp10HealthChecks: false,
}
