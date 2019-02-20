local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    envoyProxyEnabled: (slbimages.phaseNum <= 1 || configs.estate == "prd-sam"),
    roleEnabled: (slbimages.phaseNum <= 1),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    slbJournaldKillerEnabled: (slbimages.phaseNum <= 5),
    enableOnlyRunningStateProxy: (configs.estate == "prd-sdc"),
    enableNginxAccesslogs: (configs.estate == "prd-sdc"),
    removeDeprecatedIpvsProcessorFlags: (slbimages.hyperslb_build >= 2066),
    # This can probably now be removed -- see https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006IJQPIA4/view.
    ssEndpointParam: (if configs.estate == "lo2-sam" || configs.estate == "lo3-sam" then ["--secrets.ssendpoint=secretservice-%s.data.sfdc.net" % [configs.kingdom]] else []),


    # 2019/01/16 - this didn't work as expected so I disabled it (Pablo)
    # See: https://computecloud.slack.com/archives/G340CE86R/p1550291706553800
    alertOnlyOnProxyErrorCode: (slbimages.phaseNum < 1),
}
