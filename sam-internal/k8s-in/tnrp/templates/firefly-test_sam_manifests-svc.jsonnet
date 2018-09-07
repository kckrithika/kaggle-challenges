local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
{
  local package = packagesvc {
      serviceConf:: super.serviceConf {
          repoName: "tsm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test_sam_manifests",
          },
          {
              name: "packageQ",
              value: "test_sam_manifests.package",
          },
          {
              name: "promotionQ",
              value: "test_sam_manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "test_sam_manifests.latestfile",
          },
     ],
  },
  local pullrequest = pullrequestsvc {
      serviceConf:: super.serviceConf {
          repoName: "tsm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test_sam_manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "test_sam_manifests.pr",
          },
          {
              name: "rabbitMqExchangeName",
              value: "firefly.delivery",
          },
     ],

  },
  local promotion = promotionsvc {
      serviceConf:: super.serviceConf {
          repoName: "tsm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test_sam_manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "test_sam_manifests.promotion",
          },
          {
              name: "rabbitMqExchangeName",
              value: "firefly.delivery",
          },
     ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, pullrequest.items, promotion.items]),

}
else "SKIP"
