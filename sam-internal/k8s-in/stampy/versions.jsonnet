local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
    injectorNamespace: (
        // k8s namespace to which the stampy webhook should be deployed
        "stampy-webhook"
    ),

    // ========
    // WEBHOOK IMAGE
    // ========
    stampyWebhookImage: (
        // need to use a full image path. relative paths like 'dva/stampy-webhook-admission-controller-1p' won't work here.

        if utils.is_pcn(configs.kingdom) then 
            "%s/docker-gcp/stampy-webhook-admission-controller-1p:14" % configs.registry
        else
            "%s/dva/stampy-webhook-admission-controller-1p:14" % configs.registry
    ),
}
