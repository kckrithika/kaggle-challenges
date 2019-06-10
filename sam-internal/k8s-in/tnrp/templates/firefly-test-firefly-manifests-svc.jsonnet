local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local prConfig = import "configs/firefly-pullrequest.jsonnet";
local artifactoryConfig = import "configs/firefly-artifactory.jsonnet";

if configs.estate == "prd-sam" then
{
  local package = packagesvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "test-firefly-manifests",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "sam-test-firefly-manifests.package",
          },
          {
              name: "PROMOTION_QUEUE",
              value: "sam-test-firefly-manifests.promotion",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "sam-test-firefly-manifests.latestfile",
          },
     ],
  },
  local packagesingleton = packagesvcsingleton {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "test-firefly-manifests",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "sam-test-firefly-manifests.package",
          },
          {
              name: "PROMOTION_QUEUE",
              value: "sam-test-firefly-manifests.promotion",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "sam-test-firefly-manifests.latestfile",
          },
     ],
  },
  local pullrequest = pullrequestsvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "test-firefly-manifests",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "sam-test-firefly-manifests.pr",
          },
     ],
     data:: {
        local appConfig = prConfig.config("firefly-pullrequest") + {
          appconfig+: {
            artifactory: artifactoryConfig.prod,
          },
        },
        "application.yml": std.manifestJson(appConfig),
     },
  },
  local promotion = promotionsvc {
      serviceConf:: super.serviceConf {
          repoName: "tfm",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "test-firefly-manifests",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "sam-test-firefly-manifests.promotion",
          },
     ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
