local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";

if configs.estate == "prd-samtwo" then
{
    local p = packagesvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        env:: super.env + [
            {
                name: "instanceType",
                value: "manifests",
            },
            {
                name: "packageQ",
                value: "test-manifests.package",
            },
            {
                name: "promotionQ",
                value: "test-manifests.promotion",
            },
            {
                name: "latestfileQ",
                value: "test-manifests.latestfile",
            },
       ],

    },
    local r = pullrequestsvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        env:: super.env + [
            {
                name: "instanceType",
                value: "test-manifests",
            },
            {
                name: "rabbitmqQueueName",
                value: "test-manifests.pr",
            },
            {
                name: "rabbitMqExchangeName",
                value: "firefly.delivery",
            },
       ],

    },
    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([p.items, r.items]),
}
else "SKIP"
