local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local images = import "fireflyimages.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local prConfig = import "configs/firefly-pullrequest.jsonnet";

if configs.estate == "prd-samtwo" then
{
  local package = packagesvc {
      serviceName:: "firefly-package-fcp-spin",
      dockerImage:: images.fireflypackagespin,
      replicas:: 3,
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-spin",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-fcp-spin.package",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-fcp-spin.latestfile",
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
                {
                  "environment-type": "dev1",
                  region: "us-west-2",
                  "access-key-id": "${dev1_service_firefly_key#FromSecretService}",
                  "secret-access-key": "${dev1_service_firefly_secret#FromSecretService}",
                  "role-arn": "${dev1RoleArn#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-helm-archive",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-fcp-archive",
                    },
                    ],
                  },
                },
                {
                  "environment-type": "prod",
                  region: "us-east-2",
                  "access-key-id": "${ESVC1_service_firefly_key#FromSecretService}",
                  "secret-access-key": "${ESVC1_service_firefly_secret#FromSecretService}",
                  "role-arn": "${prodRoleArn#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-helm-archive",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-fcp-archive",
                    },
                    ],
                  },
                },
              ],
            },
            "s3-bucket": "fcparchive",
            'deliver-to-1p': 'false',
          },
        },
       "application.yml": std.manifestJson(appConfig),
     },
  },
  local packagesingleton = packagesvcsingleton {
      serviceName:: "firefly-package-singleton-fcp-spin",
      dockerImage:: images.fireflypackagespin,
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-spin",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-fcp-spin.package",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-fcp-spin.latestfile",
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
                {
                  "environment-type": "dev1",
                  region: "us-west-2",
                  "access-key-id": "${dev1_service_firefly_key#FromSecretService}",
                  "secret-access-key": "${dev1_service_firefly_secret#FromSecretService}",
                  "role-arn": "${dev1RoleArn#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-helm-archive",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "dev-us-west-2-sfcd-fcp-archive",
                    },
                    ],
                  },
                },
                {
                  "environment-type": "prod",
                  region: "us-east-2",
                  "access-key-id": "${ESVC1_service_firefly_key#FromSecretService}",
                  "secret-access-key": "${ESVC1_service_firefly_secret#FromSecretService}",
                  "role-arn": "${prodRoleArn#FromSecretService}",
                  "bucket-configs-by-type": {
                    helm: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-helm-archive",
                    },
                    ],
                    terraform: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-terraform",
                    },
                    ],
                    fcp: [
                    {
                      "bucket-name": "esvc-us-east-2-sfcd-fcp-archive",
                    },
                    ],
                  },
                },
              ],
            },
            "s3-bucket": "fcparchive",
            'deliver-to-1p': 'false',
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
  },
  local pullrequest = pullrequestsvc {
      serviceName:: "firefly-pullrequest-fcp-spin",
      replicas:: 2,
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-fcp-spin",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "firefly-fcp-spin.pr",
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
