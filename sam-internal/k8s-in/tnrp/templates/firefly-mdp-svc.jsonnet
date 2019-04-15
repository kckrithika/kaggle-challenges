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
      serviceConf:: super.serviceConf {
          repoName: "mdp",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-mdp",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-mdp.package",
          },
          {
              name: "PROMOTION_QUEUE",
              value: "firefly-mdp.promotion",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-mdp.latestfile",
          },
     ],
     data:: {
       local appConfig = packageConfig.config("firefly-package") + {
         appconfig+: {
            "multi-repo-supported": true,
            docker+: {
              "force-create-container": true,
            },
          },
        },
       "application.yml": std.manifestJson(appConfig),
     },
  },
  local packagesingleton = packagesvcsingleton {
      serviceConf:: super.serviceConf {
          repoName: "mdp",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-mdp",
          },
          {
              name: "PACKAGE_QUEUE",
              value: "firefly-mdp.package",
          },
          {
              name: "PROMOTION_QUEUE",
              value: "firefly-mdp.promotion",
          },
          {
              name: "LATEST_FILE_QUEUE",
              value: "firefly-mdp.latestfile",
          },
      ],
      data:: {
        local appConfig = packageConfig.config("firefly-package") + {
         appconfig+: {
            "multi-repo-supported": true,
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
  },
  local pullrequest = pullrequestsvc {
      serviceConf:: super.serviceConf {
          repoName: "mdp",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-mdp",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "firefly-mdp.pr",
          },
      ],
      data:: {
        local appConfig = prConfig.config("firefly-pullrequest") + {
          appconfig+: {
            "multi-repo-supported": true,
            "self-auth-allowed": false,
            docker+: {
              "force-create-container": true,
            },
          },
        },
        "application.yml": std.manifestJson(appConfig),
      },
  },
  local promotion = promotionsvc {
      serviceConf:: super.serviceConf {
          repoName: "mdp",
      },
      env:: super.env + [
          {
              name: "INSTANCE_TYPE",
              value: "firefly-mdp",
          },
          {
              name: "RABBIT_MQ_QUEUE_NAME",
              value: "firefly-mdp.promotion",
          },
     ],

  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, promotion.items]),

}
else "SKIP"
