local serviceDeployment = import "sfcdapi-service-deployment.jsonnet.TEMPLATE";
local images = import "sfcdimages.jsonnet";
local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local sfcd_feature_flags = import "sfcd_feature_flags.jsonnet";
local firebomConfig = import "configs/firebom-webhook.jsonnet";
local sfcdConfigs = import "sfcdconfigs.jsonnet";

if sfcd_feature_flags.is_firebom_webhook_enabled then {
  local firebomWebhook = serviceDeployment {
    serviceConf:: {
      healthPort: portConfig.sfcdapi.firebom_mgmt,
      pool: if configs.estate == "prd-samtwo" then 'prd-sam_tnrp_promoter' else configs.estate,
      port: [
        {
          name: "sfcdapifb-http",
          protocol: "TCP",
          containerPort: portConfig.sfcdapi.firebom_http,
        },
      ],
    },
    serviceName:: "sfcdapi-firebom-webhook",
    namespace:: "sfcd",
    role:: "sfcd.sfcd-api",
    dockerImage:: images.sfcdapifirebomwebhook,
    portAnnotations:: [
      {
         port: portConfig.sfcdapi.firebom_mgmt,
         targetPort: portConfig.sfcdapi.firebom_mgmt,
         lbtype: "http",
         tls: true,
         reencrypt: false,
         sticky: 0,
      },
      {
         port: portConfig.sfcdapi.firebom_https,
         targetPort: portConfig.sfcdapi.firebom_http,
         lbtype: "http",
         tls: true,
         reencrypt: false,
         sticky: 0,
      },
    ],
    portConfigs:: [
      {
        name: 'sfcdapifb-https',
        protocol: 'TCP',
        port: portConfig.sfcdapi.firebom_https,
        targetPort: portConfig.sfcdapi.firebom_http,
        [if !sfcd_feature_flags.is_slb_enabled then "nodePort"]: portConfig.sfcdapi.firebom_https_nodeport,
      },
      {
        name: 'admin-port',
        protocol: 'TCP',
        port: portConfig.sfcdapi.firebom_mgmt,
        targetPort: portConfig.sfcdapi.firebom_mgmt,
        [if !sfcd_feature_flags.is_slb_enabled then "nodePort"]: portConfig.sfcdapi.firebom_mgmt_nodeport,
      },
    ],
    replicas:: 1,
    command:: ["java", "-jar", "/sfcdapi-firebom-svc.jar", "--spring.profiles.active=sfcd-api", "--spring.config.location=/etc/sfcdapi-firebom-webhook/config/"],
    env:: super.commonEnv + [
      {
        name: "CONFIG_VERSION",
        value: sfcdConfigs.sfcdapifirebomwebhook,
      },
    ],
    volumeMounts:: super.commonVolMounts,
    data:: {
      "application.yml": std.manifestJson(firebomConfig.config("sfcdapi-firebom-webhook")),
    },
  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([firebomWebhook.items]),
} else "SKIP"
