local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: (configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam" || configs.estate == "prd-samtwo" || configs.estate == "phx-sam" || configs.estate == "dfw-sam"),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),

    # slb-nginx-accesslogs can sometimes fill up disk -- see investigation at
    # https://computecloud.slack.com/archives/G340CE86R/p1552882461719300?thread_ts=1552870275.718300&cid=G340CE86R.
    nginxAccesslogsEnabled: (slbimages.phaseNum <= 3),

    # HSM nginx currently serves too few VIPs for the upstream status reporter to provide a good signal about
    # the health of upstream servers. Disable the container for now.
    # See https://computecloud.slack.com/archives/G340CE86R/p1552359954498500?thread_ts=1552346706.487600&cid=G340CE86R.
    slbUpstreamReporterEnabledForHsmNginx: (false),

    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),

    # The rollout of slb-realsvrcfg sometimes gets stuck waiting for pod termination.
    # When this happens, we observe issues with canary DSR VIP availability.
    # See discussion at https://computecloud.slack.com/archives/G340CE86R/p1555707096410000?thread_ts=1555702827.408500&cid=G340CE86R
    # Reduce the maxUnavailable for realsvrcfg from 20% to 1, so that at most one daemonset
    # pod is offline at a time.
    realsvrCfgRolloutMaxUnavailable: (if slbimages.phaseNum <= 3 then 1 else "20%"),


    # Fix logging for slb-nginx-data-watchdog and slb-nginx-data pods
    fixNginxDataLogging: (slbimages.phaseNum <= 3),

    # Enable kms config map to fix placement of kingdom json files in nginx-proxy container within the hsm nginx pods
    kmsConfigMap: (slbimages.phaseNum <= 1 || configs.estate == "dfw-sam" || configs.estate == "phx-sam"),

    # Use new /healthz endpoint with heartbeating for portal liveness probes.
    portalHealthzProbe: (slbimages.phaseNum <= 2),
}
