local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";

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
     data:: {
          local appConfig = packageConfig.config("firefly-package") + {
            appconfig+: {
              s3: {
              enabled: true,
              "s3-access-key-id": "${s3AccessKeyId#FromSecretService}",
              "s3-secret-access-key": "${s3SecretAccessKey#FromSecretService}",
            },
            "s3-bucket": "fcparchive",
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
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
