local configs = import "config.jsonnet";

{
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:3b72dddee5c16c66043662b5ec6205dfdef08e2f" % configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sconelibci.dop.sfdc.net/job/servicelibs/job/sherpa-injector/job/master/113
        "%s/sfci/servicelibs/sherpa-injector:9a055d6b5d391f30318a848432f4cfa409033703" % configs.registry
    ),
    canarySherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/commits/master
        "%s/sfci/servicelibs/sherpa-envoy:3b72dddee5c16c66043662b5ec6205dfdef08e2f" % configs.registry
    ),
}
