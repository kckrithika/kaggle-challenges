local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local evalresultmonitor = import "firefly-evalresultmonitor.jsonnet.TEMPLATE";

if configs.estate == "prd-samtwo" then
{
    local package = packagesvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "manifests.latestfile",
            },
       ],

    },
    local packagesingleton = packagesvcsingleton {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "manifests.latestfile",
            },
       ],
    },
    local pullrequest = pullrequestsvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "manifests.pr",
            },
       ],

    },
    local promotion = promotionsvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "manifests.promotion",
            },
       ],

    },
    local evrmonitor = evalresultmonitor {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
            darkLaunch: "true",
        },
        replicas:: 1,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "manifests.pr",
            },
            {
                name: "EVAL_RESULT_MONITOR_QUEUE",
                value: "evalresultmonitor.manifests.pr",
            },
       ],

    },

    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items, evrmonitor.items]),
}
else "SKIP"
