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
        if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 
            "%s/dva/stampy-webhook-admission-controller-1p:20" % configs.registry
        else if configs.estate == "prd-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "xrd-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "chx-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "ttd-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
    ),
}
