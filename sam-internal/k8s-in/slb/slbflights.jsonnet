{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 7 then true else false),
    nginxPodFloat: (slbimages.phaseNum <= 2),
    proxyProtocolCanaryEnabled: (slbimages.phaseNum <= 1),
    roleEnabled: (slbimages.phaseNum <= 1),
    ipvsProcessorProxySelection: (slbimages.phaseNum <= 0),
}
