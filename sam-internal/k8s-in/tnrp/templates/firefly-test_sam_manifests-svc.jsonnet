local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-sam" then
{
  local package = packagesvc {
    serviceName:: "firefly-package-tsm",
    selectorName:: "firefly-package",
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "PACKAGE_QUEUE",
        value: "tnrpfirefly-test_sam_manifests.package",
      },
      {
        name: "PROMOTION_QUEUE",
        value: "tnrpfirefly-test_sam_manifests.promotion",
      },
      {
        name: "LATEST_FILE_QUEUE",
        value: "tnrpfirefly-test_sam_manifests.latestfile",
      },
   ],
  },
  local packagesingleton = packagesvcsingleton {
     serviceName:: "firefly-package-singleton-tsm",
     selectorName:: "firefly-package-singleton",
     replicas:: 1,
     env:: super.env + [
       {
         name: "INSTANCE_TYPE",
         value: "test_sam_manifests",
       },
       {
         name: "PACKAGE_QUEUE",
         value: "tnrpfirefly-test_sam_manifests.package",
       },
       {
         name: "PROMOTION_QUEUE",
         value: "tnrpfirefly-test_sam_manifests.promotion",
       },
       {
         name: "LATEST_FILE_QUEUE",
         value: "tnrpfirefly-test_sam_manifests.latestfile",
       },
    ],
  },
  local pullrequest = pullrequestsvc {
    serviceName:: "firefly-pullrequest-tsm",
    selectorName:: "firefly-pullrequest",
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "RABBIT_MQ_QUEUE_NAME",
        value: "tnrpfirefly-test_sam_manifests.pr",
      },
   ],
  },
  local promotion = promotionsvc {
    serviceName:: "firefly-promotion-tsm",
    selectorName:: "firefly-promotion",
    replicas:: 1,
    env:: super.env + [
      {
        name: "INSTANCE_TYPE",
        value: "test_sam_manifests",
      },
      {
        name: "RABBIT_MQ_QUEUE_NAME",
        value: "tnrpfirefly-test_sam_manifests.promotion",
      },
   ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
