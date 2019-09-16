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
        "%s/dva/electron_opa:5-abe14d5cf848440ecc9d517baf63a77cdc2efd4a" % configs.registry
    ),

    // =========
    // OPA-ISTIO
    // =========
    opaIstioImage: (
        // need to use a full image path. relative paths like 'dva/electron_opa_istio' won't work here.
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/openpolicyagent/opa:0.13.2-istio-with-config-2"
    ),

    // =========
    // INJECTOR
    // =========
    injectorImage: (
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "%s/dva/electron-opa-injection-webhook:13-9f0086286a437162b1c276134c1b6c12f627a1a6" % configs.registry
    ),
}
