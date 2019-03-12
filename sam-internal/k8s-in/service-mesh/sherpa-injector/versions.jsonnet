local configs = import "config.jsonnet";

{
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:6c67c98234e9f47f2ff9bb9c5c90acc6ac390be7" % configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/109
        "%s/sfci/servicelibs/sherpa-injector:9637c42ce66eb71611328c9ea47cb5301c38673c" % configs.registry
    ),
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:6c67c98234e9f47f2ff9bb9c5c90acc6ac390be7" % configs.registry
    ),
}
