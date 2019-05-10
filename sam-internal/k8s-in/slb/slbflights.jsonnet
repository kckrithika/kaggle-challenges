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

    # slb-nginx-accesslogs can sometimes fill up disk -- see investigation at
    # https://computecloud.slack.com/archives/G340CE86R/p1552882461719300?thread_ts=1552870275.718300&cid=G340CE86R.
    nginxAccesslogsEnabled: (slbimages.hyperslb_build >= 2142),

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
    realsvrCfgRolloutMaxUnavailable: (if slbimages.hyperslb_build >= 2142 then 1 else "20%"),


    # Fix logging for slb-nginx-data-watchdog and slb-nginx-data pods
    fixNginxDataLogging: (slbimages.hyperslb_build >= 2142),

    # Use new /healthz endpoint with heartbeating for portal liveness probes.
    portalHealthzProbe: (slbimages.hyperslb_build >= 2142),

    # slb-nginx-data is generating failures because of k8s probe failures causing the process to get killed
    # This change decreases the aggressiveness of the slb-nginx-data probe
    tamerNginxDataProbes: (slbimages.phaseNum <= 5),

    # slb-dns-register's container name was (confusingly) slb-dns-register-processor. Sanitize it.
    slbDnsRegisterContainerName: (if slbimages.hyperslb_build >= 2155 then "slb-dns-register" else "slb-dns-register-processor"),

    slbFredNewNodeName: (slbimages.phaseNum <= 1),
}
