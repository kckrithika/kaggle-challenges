local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local packageConfig = import "configs/firefly-package.jsonnet";

if configs.estate == "prd-samtwo" then
{
  local package = packagesvc {
      serviceName:: "firefly-package-templates",
      selectorName:: "firefly-package",
      serviceConf:: super.serviceConf {
          dindEnabled: false,
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-templates",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-templates.package",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-templates.latestfile",
          },
     ],
     data:: {
       local appConfig = packageConfig.config("firefly-package") + {
         appconfig+: {
            gcs: {
                enabled: true,
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
            },
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
            "multi-repo-supported": true,
          },
        },
       "application.yml": std.manifestJson(appConfig),
     },
  },
  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items]),

}
else "SKIP"
