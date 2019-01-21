local configs = import "config.jsonnet";

{
    sherpaImage: (
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:1.0.5" % configs.registry
    ),
}
