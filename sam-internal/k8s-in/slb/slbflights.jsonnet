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

    # Running artifactory-bootstrap on host network allows this service to function even when there
    # are issues communicating from a node's docker subnet.
    # See https://computecloud.slack.com/archives/G340CE86R/p1554742975378400?thread_ts=1554741913.377900&cid=G340CE86R
    hostNetworkForArtifactoryBootstrap: (slbimages.phaseNum <= 2),

    # slb-nginx-accesslogs can sometimes fill up disk -- see investigation at
    # https://computecloud.slack.com/archives/G340CE86R/p1552882461719300?thread_ts=1552870275.718300&cid=G340CE86R.
    nginxAccesslogsEnabled: (slbimages.phaseNum <= 1),

    # HSM nginx currently serves too few VIPs for the upstream status reporter to provide a good signal about
    # the health of upstream servers. Disable the container for now.
    # See https://computecloud.slack.com/archives/G340CE86R/p1552359954498500?thread_ts=1552346706.487600&cid=G340CE86R.
    slbUpstreamReporterEnabledForHsmNginx: (false),

    # XRD is currently bumping into peering prefix limits (60) that restrict the number of distinct VIPs
    # we can serve before everything blows up. Disable canary VIPs (and downstream components like fred/george)
    # in XRD until we can increase the prefix limits and thus advertise more VIPs.
    # See https://computecloud.slack.com/archives/G340CE86R/p1551987919271500.
    disableCanaryVIPs: false,

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),

    # Feature flag for slb-portal to display all VIPs
    slbPortalEndpointOverride: (false && slbimages.phaseNum <= 1),
}
