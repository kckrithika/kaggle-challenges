local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-sam" then
{
  local package = packagesvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test-firefly-manifests",
          },
          {
              name: "packageQ",
              value: "test-firefly-manifests.package",
          },
          {
              name: "promotionQ",
              value: "test-firefly-manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "test-firefly-manifests.latestfile",
          },
     ],
  },
  local packagesingleton = packagesvcsingleton {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test-firefly-manifests",
          },
          {
              name: "packageQ",
              value: "test-firefly-manifests.package",
          },
          {
              name: "promotionQ",
              value: "test-firefly-manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "test-firefly-manifests.latestfile",
          },
     ],
  },
  local pullrequest = pullrequestsvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test-firefly-manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "test-firefly-manifests.pr",
          },
     ],

  },
  local promotion = promotionsvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "instanceType",
              value: "test-firefly-manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "test-firefly-manifests.promotion",
          },
     ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
