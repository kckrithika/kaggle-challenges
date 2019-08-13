local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
    injectorNamespace: (
        // k8s namespace to which the injector should be deployed
        "mesh-control-plane"
    ),

    // ======
    // SHERPA
    // ======
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:d20afbca82c0e116f897aa6d926f368f7e05255d" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:1.0.11" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),

    // ========
    // INJECTOR
    // ========
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/125
        "%s/sfci/servicelibs/sherpa-injector:9a2a032114e67e40831de6e744c26c85e1607b0e" % 
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.

        if utils.is_pcn(configs.kingdom) then 
            // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/125
            "%s/docker-gcp/sfci/servicelibs/sherpa-injector:9a2a032114e67e40831de6e744c26c85e1607b0e" % configs.registry
        else
            // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/125
            "%s/sfci/servicelibs/sherpa-injector:9a2a032114e67e40831de6e744c26c85e1607b0e" % configs.registry
    ),
}
