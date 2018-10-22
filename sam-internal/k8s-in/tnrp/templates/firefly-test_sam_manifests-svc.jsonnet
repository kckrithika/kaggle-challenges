local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-sam" then
{
  local package = packagesvc {
    serviceConf:: super.serviceConf {
      repoName: "tsm",
    },
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "PACKAGE_QUEUE",
        value: "test_sam_manifests.package",
      },
      {
        name: "PROMOTION_QUEUE",
        value: "test_sam_manifests.promotion",
      },
      {
        name: "LATEST_FILE_QUEUE",
        value: "test_sam_manifests.latestfile",
      },
   ],
  },
  local packagesingleton = packagesvcsingleton {
     serviceConf:: super.serviceConf {
       repoName: "tsm",
     },
     replicas:: 1,
     env:: super.env + [
       {
         name: "INSTANCE_TYPE",
         value: "test_sam_manifests",
       },
       {
         name: "PACKAGE_QUEUE",
         value: "test_sam_manifests.package",
       },
       {
         name: "PROMOTION_QUEUE",
         value: "test_sam_manifests.promotion",
       },
       {
         name: "LATEST_FILE_QUEUE",
         value: "test_sam_manifests.latestfile",
       },
    ],
  },
  local pullrequest = pullrequestsvc {
    serviceConf:: super.serviceConf {
      repoName: "tsm",
      darkLaunch: "true",
    },
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "RABBIT_MQ_QUEUE_NAME",
        value: "test_sam_manifests.pr",
      },
   ],

  },
  local promotion = promotionsvc {
    serviceConf:: super.serviceConf {
      repoName: "tsm",
    },
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "RABBIT_MQ_QUEUE_NAME",
        value: "test_sam_manifests.promotion",
      },
   ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
