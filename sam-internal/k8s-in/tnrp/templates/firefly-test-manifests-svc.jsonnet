local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local configs = import "config.jsonnet";

if configs.estate == "prd-samtwo" then
{
    local package = packagesvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        replicas:: 1,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-test-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-test-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-test-manifests.latestfile",
            },
        ],
        data:: {
          local appConfig = packageConfig.config("firefly-package") + {
            appconfig+: {
              gcs: {
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
              },
              "gcp-syncers": {
                config: {
                  "thread-pool-size": 2,
                  "thread-name-prefix": "gcp-syncer",
                },
                rps: {
                  "enable-syncer": true,
                  "initial-delay": 5000,
                  "sync-rate": 60000,
                  "repo-configs": {
                    "rps-gcp": {
                      "product-name-regex": ".*",
                    },
                  },
                  "gcs-bucket": "rps-spike",
                },
                rpm: {
                  "enable-syncer": true,
                  "initial-delay": 5000,
                  "sync-rate": 120000,
                  "repo-configs": {
                    "rpm-gcp": {
                      "product-name-regex": ".*",
                    },
                  },
                  "gcs-bucket": "rpm-gcp",
                },
              },
            },
          },
          "application.yml": std.manifestJson(appConfig),
        },
    },
    local packagesingleton = packagesvcsingleton {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        replicas:: 1,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "sam-test-manifests.package",
            },
            {
                name: "PROMOTION_QUEUE",
                value: "sam-test-manifests.promotion",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "sam-test-manifests.latestfile",
            },
       ],
    },
    local pullrequest = pullrequestsvc {
        serviceConf:: super.serviceConf {
            repoName: "test-manifests",
        },
        replicas:: 1,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "test-manifests",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "sam-test-manifests.pr",
            },
       ],

    },
    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items]),
}
else "SKIP"
