local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local prConfig = import "configs/firefly-pullrequest.jsonnet";

if configs.estate == "prd-samtwo" then
{
  local package = packagesvc {
      serviceName:: "firefly-package-fcp-test",
      replicas:: 1,
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-test",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-fcp-test.package",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-fcp-test.latestfile",
          },
     ],
     data:: {
       local appConfig = packageConfig.config("firefly-package") + {
         appconfig+: {
            "multi-repo-supported": true,
            docker+: {
              "force-create-container": true,
            },
            gcs: {
              enabled: true,
              "service-account-key": "${gcsUploaderKey#FromSecretService}",
            },
            "gcs-bucket": "fcparchive",
            s3: {
              enabled: true,
              "s3-access-key-id": "${s3AccessKeyId#FromSecretService}",
              "s3-secret-access-key": "${s3SecretAccessKey#FromSecretService}",
              "s3-grid-configs": [
              {
                  "environment-type": "ffdev",
                  region: "us-east-2",
                  "access-key-id": "${s3AccessKeyId#FromSecretService}",
                  "secret-access-key": "${s3SecretAccessKey#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "sfcd-helm",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "fcparchive",
                    },
                    ],
                  },
                },
              ],
            },
            "s3-bucket": "fcparchive",
            gus+: {
              enable_gus_case_check: true,
            },
          },
        },
       "application.yml": std.manifestJson(appConfig),
     },
  },
  local packagesingleton = packagesvcsingleton {
      serviceName:: "firefly-package-singleton-fcp-test",
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-test",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-fcp-test.package",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-fcp-test.latestfile",
          },
      ],
      data:: {
        local appConfig = packageConfig.config("firefly-package") + {
         appconfig+: {
            "multi-repo-supported": true,
            docker+: {
              "force-create-container": true,
            },
            gcs: {
              enabled: true,
              "service-account-key": "${gcsUploaderKey#FromSecretService}",
            },
            "gcs-bucket": "fcparchive",
            s3: {
              enabled: true,
              "s3-access-key-id": "${s3AccessKeyId#FromSecretService}",
              "s3-secret-access-key": "${s3SecretAccessKey#FromSecretService}",
              "s3-grid-configs": [
              {
                  "environment-type": "ffdev",
                  region: "us-east-2",
                  "access-key-id": "${s3AccessKeyId#FromSecretService}",
                  "secret-access-key": "${s3SecretAccessKey#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "sfcd-helm",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "fcparchive",
                    },
                    ],
                  },
                },
              ],
            },
            "s3-bucket": "fcparchive",
            gus+: {
              enable_gus_case_check: true,
            },
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
  },
  local pullrequest = pullrequestsvc {
      serviceName:: "firefly-pullrequest-fcp-test",
      replicas:: 1,
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-test",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "firefly-fcp-test.pr",
          },
      ],
      data:: {
        local appConfig = prConfig.config("firefly-pullrequest") + {
          appconfig+: {
            "multi-repo-supported": true,
            "self-auth-allowed": true,
            docker+: {
              "force-create-container": true,
            },
            gus+: {
              enable_gus_case_check: true,
              enforce_gus_case_check: false,
            },
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items]),

}
else "SKIP"
