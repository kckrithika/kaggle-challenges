local serviceDeployment = import "firefly-service-deployment.jsonnet.TEMPLATE";
local images = import "fireflyimages.jsonnet";
local portConfig = import "portconfig.jsonnet";
local configs = import "config.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local intakeConfig = import "configs/firefly-intake-dl.jsonnet";
local fireflyConfigs = import "fireflyconfigs.jsonnet";

# we don't want to enable crawler for dark launch so enabling estates individually for intake
#if firefly_feature_flags.is_firefly_svc_enabled then
if configs.estate == "prd-samtwo" then
{
  local intakeservice = serviceDeployment {
      serviceConf:: {
          dindEnabled: false,
          healthPort: portConfig.firefly.intake_dl_mgmt,
          pool: if configs.estate == "prd-samtwo" then 'prd-sam_tnrp_signer' else configs.estate,
          port: [
              {
                  name: "intake-http",
                  protocol: "TCP",
                  containerPort: portConfig.firefly.intake_dl_http,
              },
          ],
      },
      serviceName:: "firefly-intake-dl",
      role:: "firefly",
      dockerImage:: images.fireflyintake,
      portAnnotations:: [
          {
                 port: portConfig.firefly.intake_dl_mgmt,
                 targetPort: portConfig.firefly.intake_dl_mgmt,
                 lbtype: "http",
                 tls: false,
                 reencrypt: false,
                 sticky: 0,
          },
          {
                 port: portConfig.firefly.intake_dl_http,
                 targetPort: portConfig.firefly.intake_dl_http,
                 lbtype: "http",
                 tls: false,
                 reencrypt: false,
                 sticky: 0,
          },
          {
                 port: portConfig.firefly.intake_dl_https,
                 targetPort: portConfig.firefly.intake_dl_http,
                 lbtype: "http",
                 tls: true,
                 reencrypt: false,
                 sticky: 0,
          },
      ],
      portConfigs:: [
          {
              name: 'intake-http',
              protocol: 'TCP',
              port: portConfig.firefly.intake_dl_http,
              targetPort: portConfig.firefly.intake_dl_http,
              [if !firefly_feature_flags.is_slb_enabled then "nodePort"]: portConfig.firefly.intake_dl_http_nodeport,
          },
          {
              name: 'intake-https',
              protocol: 'TCP',
              port: portConfig.firefly.intake_dl_https,
              targetPort: portConfig.firefly.intake_dl_http,
              [if !firefly_feature_flags.is_slb_enabled then "nodePort"]: portConfig.firefly.intake_dl_https_nodeport,
          },
          {
              name: 'admin-port',
              protocol: 'TCP',
              port: portConfig.firefly.intake_dl_mgmt,
              targetPort: portConfig.firefly.intake_dl_mgmt,
              [if !firefly_feature_flags.is_slb_enabled then "nodePort"]: portConfig.firefly.intake_dl_mgmt_nodeport,
          },
      ],
      replicas:: 1,
      command:: ["java", "-jar", "/intake-svc.jar", "--spring.profiles.active=" + configs.estate, "--spring.config.location=/etc/firefly/config/"],
      env:: super.commonEnv + [
          {
              name: "CONFIG_VERSION",
              value: fireflyConfigs.fireflyintake,
          },
          {
              name: "DARKLAUNCH",
              value: "true",
          },
      ],
      volumeMounts:: super.commonVolMounts,
      data:: {
          "application.yml": std.manifestJson(intakeConfig.config("firefly-intake")),
      },
  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([intakeservice.items]),
} else "SKIP"
