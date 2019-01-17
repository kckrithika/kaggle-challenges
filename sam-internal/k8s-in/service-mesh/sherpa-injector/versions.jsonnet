local configs = import "config.jsonnet";

{
    sherpaImage: (
            "%s/sfci/servicelibs/sherpa-envoy:478036ff96fe4c7b188fef57fd0437d0795252c5" % configs.registry
    ),
}
