local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-sam" then
{
  local package = packagesvc {
      serviceConf:: super.serviceConf {
          repoName: "stgmanifests",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "staging_sam_manifests",
          },
          {
              name: "packageQ",
              value: "staging_sam_manifests.package",
          },
          {
              name: "promotionQ",
              value: "staging_sam_manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "staging_sam_manifests.latestfile",
          },
     ],
  },
  local packagesingleton = packagesvcsingleton {
      serviceConf:: super.serviceConf {
          repoName: "stgmanifests",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "staging_sam_manifests",
          },
          {
              name: "packageQ",
              value: "staging_sam_manifests.package",
          },
          {
              name: "promotionQ",
              value: "staging_sam_manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "staging_sam_manifests.latestfile",
          },
     ],
  },
  local pullrequest = pullrequestsvc {
      serviceConf:: super.serviceConf {
          repoName: "stgmanifests",
      },
      replicas:: 2,
      env:: super.env + [
          {
              name: "instanceType",
              value: "staging_sam_manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "staging_sam_manifests.pr",
          },
          {
              name: "rabbitMqExchangeName",
              value: "firefly.delivery",
          },
     ],

  },
  local promotion = promotionsvc {
      serviceConf:: super.serviceConf {
          repoName: "stgmanifests",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "staging_sam_manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "staging_sam_manifests.promotion",
          },
          {
              name: "rabbitMqExchangeName",
              value: "firefly.delivery",
          },
     ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
