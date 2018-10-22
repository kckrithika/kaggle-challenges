{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = import "slbconfig.jsonnet",
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 4 then true else false),
    cnameRegisterEnabled: (slbimages.phaseNum <= 2),
    nginxPodFloat: (slbimages.phaseNum <= 1),
    proxyProtocolCanaryEnabled: (slbimages.phaseNum <= 1),
    roleEnabled: (slbimages.phaseNum <= 1),

    getIPVSConsistencyIgnoreServerWeights():: (if slbimages.hypersdn_build >= 1288 then [
        "--ignoreWeightsInConsistencyCheck=true",
    ] else []),
}
