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
    proxyHealthChecksFlagRemoved: (slbimages.hypersdn_build < 1317),
    trustedProxies: (slbimages.phaseNum <= 7),
    ipvsProcessorProxySelection: (slbimages.phaseNum <= 0),

    // Phase out this deprecated command-line option. Once it has been removed globally,
    // the corresponding toggle at https://git.soma.salesforce.com/sdn/sdn/blob/ab2fbbb9692795858829f49ed5c74bfe3e836607/src/slb/slb-config-processor/main.go#L190-L192
    // can be removed.
    alwaysPopulateRealServersParam():: (if slbimages.hypersdn_build < 1308 then [
        "--alwaysPopulateRealServers=true",
    ] else []),
}
