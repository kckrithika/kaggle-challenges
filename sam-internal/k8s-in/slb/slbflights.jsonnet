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
    slbUpstreamReporterEnabled: (if (slbimages.phaseNum <= 3 && slbimages.hyperslb_build >= 2071) || slbimages.hyperslb_build >= 2072 then true else false),
    slbTCPdumpEnabled: (slbimages.phaseNum <= 1),
    nginAccesslogsRunInSlbEstate: (slbimages.hyperslb_build >= 2072),

    # Portal's root endpoint (`/`) queries DNS for every page load. VIP watchdog (reachability on the target port and VIP availability) and kubelet
    # (liveness probe) both hit this endpoint every 3 seconds, causing undue stress on DNS lookups. Change the liveness probe endpoint to something
    # less dependent on external systems. Unfortunately, VIP watchdog's reachability probe can't be similarly configured.
    # https://gus.lightning.force.com/a07B0000006QrWiIAK (when implemented) should help with portal's page load times.
    # https://gus.lightning.force.com/a07B0000005jkagIAA (when implemented) should allow us to reduce VIP watchdog's load on the main portal page.
    portalLivenessProbeEndpoint: (if slbimages.phaseNum <= 1 then "/webfiles/" else "/"),

    # XRD is currently bumping into peering prefix limits (60) that restrict the number of distinct VIPs
    # we can serve before everything blows up. Disable canary VIPs (and downstream components like fred/george)
    # in XRD until we can increase the prefix limits and thus advertise more VIPs.
    # See https://computecloud.slack.com/archives/G340CE86R/p1551987919271500.
    disableCanaryVIPs: (configs.kingdom == "xrd"),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),
}
