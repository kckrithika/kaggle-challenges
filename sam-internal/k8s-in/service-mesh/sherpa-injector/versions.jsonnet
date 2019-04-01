local configs = import "config.jsonnet";

{
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:3b72dddee5c16c66043662b5ec6205dfdef08e2f" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:3b72dddee5c16c66043662b5ec6205dfdef08e2f" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/128
        "%s/sfci/servicelibs/sherpa-injector:ae6a9e43391b9135ec87d3a1914ccd7c2be37eea" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/128
        "%s/sfci/servicelibs/sherpa-injector:ae6a9e43391b9135ec87d3a1914ccd7c2be37eea" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
}
