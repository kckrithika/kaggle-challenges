{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = import "slbconfig.jsonnet",
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 4 then true else false),
    cnameRegisterEnabled: (slbimages.phaseNum <= 0),
    nginxPodFloat: (slbimages.phaseNum <= 1),

    getIPVSHealthCheckRiseFallSettings():: (if slbimages.phaseNum <= 3 then [
            // Defaults are currently rise=2, fall=3 (https://git.soma.salesforce.com/sdn/sdn/blob/assert-validation-succeeds/src/slb/slb-ipvs-processor/healthcheckmanager/health_check_manager.go#L20-L21).
            // Flighting change to make this rise=5, fall=2 -- being treated as healthy should require a higher bar than being treated as unhealthy.
            // Note that current nginx config is hard-coded to rise=2, fall=5 (https://git.soma.salesforce.com/sdn/sdn/blob/assert-validation-succeeds/src/slb/slb-nginx-config/commonconfig/commonconfig.go#L147-L152).
            "--healthcheck.riseCount=5",
            "--healthcheck.fallCount=2",
        ] else []),

    getIPVSConsistencyIgnoreServerWeights():: (if slbimages.hypersdn_build >= 1288 then [
        "--ignoreWeightsInConsistencyCheck=true",
    ] else []),
}
