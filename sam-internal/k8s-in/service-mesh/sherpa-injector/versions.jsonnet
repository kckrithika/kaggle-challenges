local configs = import "config.jsonnet";

{
    sherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:1.0.5" % configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/57
        "%s/sfci/servicelibs/sherpa-injector:d1d2f47de934515222575ff448bdac3f6173fe9d" % configs.registry
    ),    
}
