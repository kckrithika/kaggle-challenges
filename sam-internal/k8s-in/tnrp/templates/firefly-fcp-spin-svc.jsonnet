local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local images = import "fireflyimages.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local prConfig = import "configs/firefly-pullrequest.jsonnet";
local s3Config = import "configs/firefly-s3.jsonnet";

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
            s3: s3Config.s3,
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
            s3: s3Config.s3,
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
