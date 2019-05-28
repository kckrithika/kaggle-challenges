local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";

if configs.estate == "prd-samtwo" then
{
    local package = packagesvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-manifests.latestfile",
            },
       ],
       data:: {
         local appConfig = packageConfig.config("firefly-package") + {
           appconfig+: {
              gcs: {
                enabled: false,
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
              },
              "gcs-bucket": "fcp_archive",
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
            repoName: "manifests",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-manifests.latestfile",
            },
       ],
       data:: {
         local appConfig = packageConfig.config("firefly-package") + {
           appconfig+: {
              gcs: {
                enabled: false,
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
              },
              "gcs-bucket": "fcp_archive",
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
    local pullrequest = pullrequestsvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-manifests.pr",
            },
       ],

    },
    local promotion = promotionsvc {
        serviceConf:: super.serviceConf {
            repoName: "manifests",
        },
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-manifests.promotion",
            },
       ],

    },
    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),
}
else "SKIP"
