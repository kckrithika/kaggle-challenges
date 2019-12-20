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

    // phase1 = DEV env (prd-samdev and prd-samtest)
    "1" : {
        canarySherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:410b9b128bae61fe3db928569412ea9dd07dfa0e" % if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry),
        sherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:1.0.13" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry),
        
    },
    // phase2 = TEST env (prd-sam)
    "2" : {
        canarySherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:410b9b128bae61fe3db928569412ea9dd07dfa0e" % if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry),
        sherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:1.0.13" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry),
        
    },
    // phase3 = PROD env (par etc...)
    "3" : {
        canarySherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:410b9b128bae61fe3db928569412ea9dd07dfa0e" % if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry),
        sherpaImage: ("%s/sfci/servicelibs/sherpa-envoy:1.0.13" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry)
    },

    // ========
    // INJECTOR
    // ========
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master
        "%s/sfci/servicelibs/sherpa-injector:366885d38c46e57ca9810a687c3e0d2529df8e76" %
        if utils.is_pcn(configs.kingdom) then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        if configs.kingdom == "prd" then
            "%s/sfci/servicelibs/sherpa-injector:55ea0f4557b95322a0e8a0bb0f86121aecdec550" % configs.registry
        else
            // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master
            "%s/sfci/servicelibs/sherpa-injector:9a2a032114e67e40831de6e744c26c85e1607b0e" % configs.registry 
    ),
}
