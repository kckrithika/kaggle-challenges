{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 4 then true else false),
    nginxPodFloat: (slbimages.phaseNum <= 2),
    proxyProtocolCanaryEnabled: (slbimages.phaseNum <= 1),
    roleEnabled: (slbimages.phaseNum <= 1),
    podLevelLogEnabled: (slbimages.phaseNum <= 3),

    slbCleanupLogsVolume():: (if $.podLevelLogEnabled then [
            slbconfigs.slb_config_volume,
            slbconfigs.cleanup_logs_volume,
        ] else []),

    slbCleanupLogsContainer():: (if $.podLevelLogEnabled then slbshared.slbLogCleanup else null),

    // Phase out this deprecated command-line option. Once it has been removed globally,
    // the corresponding toggle at https://git.soma.salesforce.com/sdn/sdn/blob/ab2fbbb9692795858829f49ed5c74bfe3e836607/src/slb/slb-config-processor/main.go#L190-L192
    // can be removed.
    alwaysPopulateRealServersParam():: (if slbimages.hypersdn_build < 1308 then [
        "--alwaysPopulateRealServers=true",
    ] else []),
}
