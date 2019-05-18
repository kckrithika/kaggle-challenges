local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),

    # HSM nginx currently serves too few VIPs for the upstream status reporter to provide a good signal about
    # the health of upstream servers. Disable the container for now.
    # See https://computecloud.slack.com/archives/G340CE86R/p1552359954498500?thread_ts=1552346706.487600&cid=G340CE86R.
    slbUpstreamReporterEnabledForHsmNginx: (false),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),

    # slb-nginx-data is generating failures because of k8s probe failures causing the process to get killed
    # This change decreases the aggressiveness of the slb-nginx-data probe
    tamerNginxDataProbes: (slbimages.phaseNum <= 5),

    # slb-dns-register's container name was (confusingly) slb-dns-register-processor. Sanitize it.
    slbDnsRegisterContainerName: (if slbimages.hyperslb_build >= 2155 then "slb-dns-register" else "slb-dns-register-processor"),

    slbFredNewNodeName: (slbimages.hyperslb_build >= 2156),

    # turn on perVip analysis for nginx upstream status reporter
    slbNginxReadyPerVip: (slbimages.phaseNum <= 1),

    # test our theory that ddi is having trouble with long-lived connections by enabling canary-creator
    # to run 24 hours (as a corollary, shift alerts to be business hours only) - start in just cdg
    slbCanaryAllHours: (slbimages.phaseNum < 1),
}
