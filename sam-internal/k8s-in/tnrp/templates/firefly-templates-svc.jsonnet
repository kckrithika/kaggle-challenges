local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local packageConfig = import "configs/firefly-package.jsonnet";

if configs.estate == "prd-samtwo" then
{
  local package = packagesvc {
      serviceConf:: super.serviceConf {
          dindEnabled: false,
          repoName: "templates",
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
                "service-account-key": "${gcsUploaderKey#FromSecretService}",
            },
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
