local configs = import "config.jsonnet";

{
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:bd9e582c021457a87412cd9a03742ad95eda0cd7" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:bd9e582c021457a87412cd9a03742ad95eda0cd7" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/133
        "%s/sfci/servicelibs/sherpa-injector:2ec3aac4e5627d385f949341e18fffc0ec58e0f1" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/133
        "%s/sfci/servicelibs/sherpa-injector:2ec3aac4e5627d385f949341e18fffc0ec58e0f1" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
}
