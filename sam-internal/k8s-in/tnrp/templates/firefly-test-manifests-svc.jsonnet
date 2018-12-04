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
            repoName: "test-manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-test-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-test-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-test-manifests.latestfile",
            },
       ],

    },
    local packagesingleton = packagesvcsingleton {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-test-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-test-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-test-manifests.latestfile",
            },
       ],
    },
    local pullrequest = pullrequestsvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-test-manifests.pr",
            },
       ],

    },
    local promotion = promotionsvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
            darkLaunch: "true",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-test-manifests.promotion",
            },
       ],

    },
    local evrmonitor = evalresultmonitor {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
            darkLaunch: "true",
        },
        replicas:: 1,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-test-manifests.pr",
            },
            {
                name: "EVAL_RESULT_MONITOR_QUEUE",
                value: "evalresultmonitor.sam-test-manifests.pr",
            },
       ],

    },

    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, evrmonitor.items]),
}
else "SKIP"
