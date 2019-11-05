local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
    injectorNamespace: (
        "authz-injector"
    ),

    newInjectorNamespace: (
        "authz-opa-webhook"
    ),

    // =========
    // OPA
    // =========
    opaImage: (
        "%s/dva/electron-opa:v0.14.2" % configs.registry
    ),

    newOpaImage: (
        "%s/dva/electron-opa:v0.14.2-1-metrics" % configs.registry
    ),

    // =========
    // OPA-ISTIO
    // =========
    opaIstioImage: (
        "%s/dva/electron-opa-istio:v0.14.2" % configs.registry
    ),

    newOpaIstioImage: (
        "%s/dva/electron-opa-istio:v0.14.2-1-metrics" % configs.registry
    ),

    // =========
    // INJECTOR
    // =========
    injectorImage: (
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "%s/dva/electron-opa-injection-webhook:22-57dec549a0dc3d87277a1e782492dc20b4968411" % configs.registry
    ),

    // =========
    // CONFIG INIT
    // =========
    configInitImage: (
        "%s/dva/collection-erb-config-gen:19-70c45ccd33d3772cd6519e1f7dfe2cf5c2bc7b0e" % configs.registry
    ),

    // =========
    // OPENCENSUS
    // =========
    opencensusImage: (
        "%s/dva/opencensus-service:13-75d5d20e22eec757a5399028a945fa0851bab367" % configs.registry
    ),
}
