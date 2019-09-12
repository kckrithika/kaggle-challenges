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
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/openpolicyagent/opa:0.11.0"
    ),

    // =========
    // OPA-ISTIO
    // =========
    opaIstioImage: (
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/openpolicyagent/opa:0.13.2-istio-with-config-2"
    ),

    // =========
    // INJECTOR
    // =========
    injectorImage: (
        // need to use a full image path. relative paths like 'dva/electron-opa-injector' won't work here.
        "ops0-artifactrepo1-0-prd.data.sfdc.net/dva/electron-opa-injection-webhook:8"
    ),
}
