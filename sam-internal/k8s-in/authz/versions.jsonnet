local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
    injectorNamespace: (
        // k8s namespace to which the injector should be deployed
        "authz-injector"
    ),

    // =========
    // OPA
    // =========
    opaImage: (
        // need to use a full image path. relative paths like 'dva/electron_opa' won't work here.
        "%s/dva/electron-opa:v0.14.2" % configs.registry
    ),

    // =========
    // OPA-ISTIO
    // =========
    opaIstioImage: (
        // need to use a full image path. relative paths like 'dva/electron_opa_istio' won't work here.
        "%s/dva/electron-opa-istio:v0.14.2" % configs.registry
    ),

    // =========
    // INJECTOR
    // =========
    injectorImage: (
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "%s/dva/electron-opa-injection-webhook:22-57dec549a0dc3d87277a1e782492dc20b4968411" % configs.registry
    ),
}
