local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local packagesvcsingleton = import "firefly-package-singleton-svc.jsonnet.TEMPLATE";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local promotionsvc = import "firefly-promotion-svc.jsonnet.TEMPLATE";
local evalresultmonitor = import "firefly-evalresultmonitor.jsonnet.TEMPLATE";
local packageConfig = import "configs/firefly-package.jsonnet";
local prConfig = import "configs/firefly-pullrequest.jsonnet";

if configs.estate == "prd-samtwo" then
{
    local package = packagesvc {
        serviceConf:: super.serviceConf {
            repoName: "fcp",
            darkLaunch: "false",
        },
        replicas:: 5,
        serviceName:: "firefly-fcp-package",
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "firefly-fcp",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "firefly-fcp.package",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "firefly-fcp.latestfile",
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
    local packagesingleton = packagesvcsingleton {
        serviceConf:: super.serviceConf {
            repoName: "fcp",
            darkLaunch: "false",
        },
        serviceName:: "firefly-fcp-package-singleton",
        replicas:: 2,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "firefly-fcp",
            },
            {
                name: "PACKAGE_QUEUE",
                value: "firefly-fcp.package",
            },
            {
                name: "LATEST_FILE_QUEUE",
                value: "firefly-fcp.latestfile",
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
            repoName: "fcp",
        },
        serviceName:: "firefly-fcp-pullrequest",
        replicas:: 5,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "firefly-fcp",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "firefly-fcp.pr",
            },
        ],
        data:: {
          local appConfig = prConfig.config("firefly-pullrequest") + {
            appconfig+: {
              "multi-repo-supported": true,
              "self-auth-allowed": true,
            },
          },
          "application.yml": std.manifestJson(appConfig),
        },
    },
    local evrmonitor = evalresultmonitor {
        serviceConf:: super.serviceConf {
            repoName: "fcp",
        },
        serviceName:: "firefly-fcp-evalresultmonitor",
        replicas:: 0,
        env:: super.env + [
            {
                name: "INSTANCE_TYPE",
                value: "firefly-fcp",
            },
            {
                name: "RABBIT_MQ_QUEUE_NAME",
                value: "firefly-fcp.pr",
            },
            {
                name: "EVAL_RESULT_MONITOR_QUEUE",
                value: "evalresultmonitor.firefly-fcp.pr",
            },
       ],
    },

    apiVersion: "v1",
    kind: "List",
    items: std.flattenArrays([package.items, packagesingleton.items, pullrequest.items, evrmonitor.items]),
}
else "SKIP"
