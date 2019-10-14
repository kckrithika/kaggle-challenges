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
        else if configs.estate == "cdg-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "cdu-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "dfw-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "fra-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "frf-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "hio-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "hnd-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "ia2-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "ia4-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else if configs.estate == "wax-sam" then
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
        else
            "%s/dva/stampy-webhook-admission-controller-1p:19" % configs.registry
    ),
}
