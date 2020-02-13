local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local packageConfig = import "configs/firefly-package.jsonnet";
local s3Config = import "configs/firefly-s3.jsonnet";

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
            s3: s3Config.s3,
            "s3-bucket": "fcparchive",
            "multi-repo-supported": true,
            "opa-dry-run-mode": "false",
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
