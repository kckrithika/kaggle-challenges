local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    roleEnabled: (slbimages.hyperslb_build >= 2199),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),

    # HSM nginx currently serves too few VIPs for the upstream status reporter to provide a good signal about
    # the health of upstream servers. Disable the container for now.
    # See https://computecloud.slack.com/archives/G340CE86R/p1552359954498500?thread_ts=1552346706.487600&cid=G340CE86R.
    slbUpstreamReporterEnabledForHsmNginx: (false),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),

    # test our theory that ddi is having trouble with long-lived connections by enabling canary-creator
    # to run 24 hours (as a corollary, shift alerts to be business hours only)
    slbCanaryAllHours: false,

    # 2019/05/22
    # Deploy slb-envoy-proxy only if hyperslb version is >= 2166.
    # This ensures dependent microservices are available.
    deploySLBEnvoyConfig: (
       slbimages.hyperslb_build >= 2166 &&  # Minimum build that contains slb-envoy-config
       slbimages.phaseNum <= 1 &&  # Current deployment phase
       (slbconfigs.isProdEstate || configs.estate == "prd-sdc")  # Only deploy to prd-sdc and ProdEstates
    ),

    # nginx-accesslogs tends to kill spinning disks, driving queue depths up to >150. See
    # https://computecloud.slack.com/archives/G340CE86R/p1559625970018500?thread_ts=1559590829.287500&cid=G340CE86R
    # for more discussion.
    # Disable nginx-accesslogs in later phases until issues discussed in the following work items are addressed.
    #   https://gus.my.salesforce.com/a07B0000006v3IOIAY
    #   https://gus.my.salesforce.com/a07B0000006v3JRIAY
    #   https://gus.my.salesforce.com/a07B0000006v3JlIAI
    #   https://gus.my.salesforce.com/a07B0000006v3KAIAY
    enableNginxAccessLogsAggregation: (slbimages.phaseNum <= 1),

    # enable slb-iwd-health
    enableIWDHealth: (slbimages.phaseNum <= 5),
}
