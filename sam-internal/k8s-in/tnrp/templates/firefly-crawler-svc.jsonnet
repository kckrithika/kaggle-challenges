local serviceDeployment = import "firefly-service-deployment.jsonnet.TEMPLATE";
local images = import "fireflyimages.jsonnet";
local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_firefly_svc_enabled then
{
  local crawlerservice = serviceDeployment {
      serviceConf:: {
          dindEnabled: false,
          healthPort: portConfig.firefly.crawler_mgmt,
          pool: if configs.estate == "prd-samtwo" then 'prd-sam_tnrp_signer' else configs.estate,
          port: [],
      },
      serviceName:: "firefly-crawler",
      role:: "firefly",
      dockerImage:: images.fireflycrawler,
      portAnnotations:: [
          {
                 port: portConfig.firefly.crawler_mgmt,
                 targetPort: portConfig.firefly.crawler_mgmt,
                 lbtype: "http",
                 tls: false,
                 reencrypt: false,
                 sticky: 0,
          },
      ],
      portConfigs:: [portConfig.service_health_port('package_mgmt_nodeport')],
      replicas:: 1,
      command:: ["java", "-jar", "/crawler-svc.jar", "--spring.profiles.active=" + configs.estate],
      env:: super.commonEnv,
      volumeMounts:: super.commonVolMounts,
  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([crawlerservice.items]),
} else "SKIP"
