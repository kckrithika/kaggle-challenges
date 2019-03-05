local configs = import "config.jsonnet";

{
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:1.0.5" % configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/98
        "%s/sfci/servicelibs/sherpa-injector:c1202dc8ed1a7815f712de03ff155d0e4c47a44c" % configs.registry
    ),
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:7c866de2c4f840082fac7f2d00aa2d93f7bee6be" % configs.registry
    ),
}
