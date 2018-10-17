{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = import "slbconfig.jsonnet",
    local nodeApiUnixSocketEnabled = true,
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local portalManifestWatcherEnabled = true,
    local manifestWatcherEnabled = true,
    local kubeDnsEnabled = false,
    mwSentinelEnabled: true,
    stockIpvsModules: (if slbimages.phaseNum > 4 then true else false),
    certDeployerEnabled: (if slbimages.phaseNum <= 4 then true else false),
    explicitDeleteLimit: (if slbimages.phaseNum <= 4 then true else false),
    readablePortConfigurationAnnotations: (slbimages.phaseNum <= 3),
    useDeprecatedCanaryDifferences: false,
    cnameRegisterEnabled: (slbimages.phaseNum <= 2),
    dnsRegisterPodFloat: true,

    getNodeApiClientSocketSettings(configDir):: (if nodeApiUnixSocketEnabled then [
                                                     "--client.socketDir=" + configDir,
                                                     "--client.dialSocket=true",
                                                 ] else []),

    getNodeApiServerSocketSettings():: (if nodeApiUnixSocketEnabled then [
                                            "--listenOnSocket=true",
                                            "--readOnly=false",
                                        ] else []),

    getValidateVIPAssignmentSubnet():: (if true then [
                                            "--subnet=" + slbconfigs.subnet + "," + slbconfigs.publicSubnet,
                                        ] else []),


    getPortalManifestWatcherIfEnabled():: (if portalManifestWatcherEnabled then [
                                            slbshared.slbManifestWatcher(),
                                        ] else []),
    getManifestWatcherIfEnabled():: (if manifestWatcherEnabled then [
                                            slbshared.slbManifestWatcher(),
                                     ] else []),

    getDnsPolicy():: (if kubeDnsEnabled then {} else { dnsPolicy: "Default" }),

    getSimpleDiffAndNewConfigGeneratorIfEnabled():: (if true then [
                                                     "--enableSimpleDiff=true",
                                                     "--newConfigGenerator=true",
                                                     "--control.nginxReloadSentinel=" + slbconfigs.slbDir + "/nginx/config/nginx.marker",
                                                 ] else []),

    getIPVSHealthCheckRiseFallSettings():: (if slbimages.phaseNum <= 2 then [
            // Defaults are currently rise=2, fall=3 (https://git.soma.salesforce.com/sdn/sdn/blob/assert-validation-succeeds/src/slb/slb-ipvs-processor/healthcheckmanager/health_check_manager.go#L20-L21).
            // Flighting change to make this rise=5, fall=2 -- being treated as healthy should require a higher bar than being treated as unhealthy.
            // Note that current nginx config is hard-coded to rise=2, fall=5 (https://git.soma.salesforce.com/sdn/sdn/blob/assert-validation-succeeds/src/slb/slb-nginx-config/commonconfig/commonconfig.go#L147-L152).
            "--healthcheck.riseCount=5",
            "--healthcheck.fallCount=2",
        ] else []),

    getCheckDuplicateVipSettings():: (if slbimages.hypersdn_build >= 1255 then [
            "--checkDuplicateVips=true",
    ] else []),
}
