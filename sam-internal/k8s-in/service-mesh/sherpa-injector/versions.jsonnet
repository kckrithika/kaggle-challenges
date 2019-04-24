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
        "%s/sfci/servicelibs/sherpa-envoy:1.0.7" % 
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:1.0.7" % 
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),

    // ========
    // INJECTOR
    // ========
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/3
        "%s/sfci/servicelibs/sherpa-injector:fb94972c5eb38ce818ff5bd2d7287e4c379ebe3d" % 
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.

        if utils.is_pcn(configs.kingdom) then 
            // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/9
            "%s/docker-gcp/sfci/servicelibs/sherpa-injector:fb94972c5eb38ce818ff5bd2d7287e4c379ebe3d" % configs.registry
        else
            // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/3
            "%s/sfci/servicelibs/sherpa-injector:fb94972c5eb38ce818ff5bd2d7287e4c379ebe3d" % configs.registry
    ),
}
