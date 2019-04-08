local configs = import "config.jsonnet";

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
        "%s/sfci/servicelibs/sherpa-envoy:b985afe5636e65db57ebef3e5ba67657c769d93d" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    sherpaImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://git.soma.salesforce.com/servicelibs/sherpa-envoy/releases
        "%s/sfci/servicelibs/sherpa-envoy:b985afe5636e65db57ebef3e5ba67657c769d93d" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),

    // ========
    // INJECTOR
    // ========
    canaryInjectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/3
        "%s/sfci/servicelibs/sherpa-injector:492713b1b7635dccc41345d6920e24c8b2ddd09d" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
    injectorImage: (
        // need to use a full image path. relative paths like 'sfci/servicelibs/sherpa-injector' won't work here.
        // https://sfcirelease.dop.sfdc.net/job/servicelibs/job/servicelibs-sherpa-injector/job/sherpa-injector/job/master/3
        "%s/sfci/servicelibs/sherpa-injector:492713b1b7635dccc41345d6920e24c8b2ddd09d" % 
        if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.registry + "/docker-gcp" else configs.registry
    ),
}
