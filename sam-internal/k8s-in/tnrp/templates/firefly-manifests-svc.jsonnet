local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local s3Config = import "configs/firefly-s3.jsonnet";

if configs.estate == "prd-samtwo" then
{
    local package = packagesvc {
        serviceName:: "firefly-package-manifests",
        selectorName:: "firefly-package",
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
                enabled: true,
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
              },
              "gcs-bucket": "fcparchive",
              s3: s3Config.s3,
              "s3-bucket": "fcparchive",
              "enable-fcp-stagger": false,
            },
          },
         "application.yml": std.manifestJson(appConfig),
       },
    },
    local packagesingleton = packagesvcsingleton {
        serviceName:: "firefly-package-singleton-manifests",
        selectorName:: "firefly-package-singleton",
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
                enabled: true,
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
              },
              "gcs-bucket": "fcparchive",
              s3: s3Config.s3,
              "s3-bucket": "fcparchive",
              "enable-fcp-stagger": false,
            },
          },
         "application.yml": std.manifestJson(appConfig),
       },
    },
    local pullrequest = pullrequestsvc {
        serviceName:: "firefly-pullrequest-manifests",
        selectorName:: "firefly-pullrequest",
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
        serviceName:: "firefly-promotion-manifests",
        selectorName:: "firefly-promotion",
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
