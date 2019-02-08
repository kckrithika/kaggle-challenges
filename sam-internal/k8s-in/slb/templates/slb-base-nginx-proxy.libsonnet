{
  dirSuffix:: "",
  local configs = import "config.jsonnet",
  local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile },
  local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
  local portconfigs = import "portconfig.jsonnet",
  local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbports = import "slbports.jsonnet",
  local slbbasedeployment = (import "slb-base-deployment.libsonnet") + { dirSuffix:: $.dirSuffix },
  local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
  local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: $.dirSuffix },

  local beforeSharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="") = [
                        slbshared.slbNginxConfig(deleteLimitOverride=deleteLimitOverride, tlsConfigEnabled=true),
                        slbshared.slbNginxProxy(proxyImage, proxyFlavor, true),
                        {
                          name: "slb-nginx-data",
                          image: slbimages.hyperslb,
                          command: [
                            "/sdn/slb-nginx-data",
                            "--target=" + slbconfigs.nginx.containerTargetDir,
                            "--connPort=" + slbports.slb.nginxDataConnPort,
                          ],
                          volumeMounts: configs.filter_empty([
                            slbconfigs.nginx.target_config_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                          ]),
                          livenessProbe: {
                            httpGet: {
                              path: "/",
                              port: slbports.slb.nginxDataConnPort,
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 3,
                          },
                        },
                        slbshared.slbFileWatcher,
                        madkub.madkubRefreshContainer(slbconfigs.nginx.certDirs),
                        {
                          name: "slb-cert-checker",
                          image: slbimages.hyperslb,
                          command: [
                            "/sdn/slb-cert-checker",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                          ],
                          volumeMounts: configs.filter_empty(
                            madkub.madkubSlbCertVolumeMounts(slbconfigs.nginx.certDirs) + [
                            slbconfigs.nginx.target_config_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                            slbconfigs.nginx.customer_certs_volume_mount,
                          ]
),
                          env: [
                            slbconfigs.node_name_env,
                          ],
                        },
  ],
local afterSharedContainers = [
                      {
                        name: "slb-cert-deployer",
                        image: slbimages.hyperslb,
                        command: [
                                   "/sdn/slb-cert-deployer",
                                   "--metricsEndpoint=" + configs.funnelVIP,
                                   "--hostnameOverride=$(NODE_NAME)",
                                   "--log_dir=" + slbconfigs.logsDir,
                                   "--custCertsDir=" + slbconfigs.nginx.customerCertsPath,
                                   configs.sfdchosts_arg,
                                 ] + (if configs.estate == "lo2-sam" && slbimages.hyperslb_build >= 2055 then ["--secrets.ssendpoint=secretservice-lo2.data.sfdc.net"] else if configs.estate == "lo3-sam" && slbimages.hyperslb_build >= 2055 then ["--secrets.ssendpoint=secretservice-lo3.data.sfdc.net"] else [])
                                 + slbconfigs.getNodeApiClientSocketSettings()
                                 + [
                                   slbconfigs.nginx.reloadSentinelParam,
                                 ],
                        volumeMounts: configs.filter_empty(
                          madkub.madkubSlbCertVolumeMounts(slbconfigs.nginx.certDirs) + [
                          slbconfigs.nginx.target_config_volume_mount,
                          slbconfigs.nginx.customer_certs_volume_mount,
                          slbconfigs.slb_volume_mount,
                          slbconfigs.logs_volume_mount,
                          configs.sfdchosts_volume_mount,
                        ]
),
                        env: [
                          slbconfigs.node_name_env,
                        ],
                      },
],

  // The nginx config wipe init container runs when a new nginx pod is first scheduled to a node.
  // It erases any files in the config directory, ensuring that any stale service config / block files
  // are removed before new nginx services start.
  local nginxConfigWipeInitContainer = {
    name: "slb-nginx-config-wipe",
    image: slbimages.hyperslb,
    command: [
      "/bin/bash",
      "-xec",
      "rm -rf %s/*" % [slbconfigs.nginx.containerTargetDir],
    ],
    volumeMounts: [
      slbconfigs.nginx.target_config_volume_mount,
    ],
  },

  slbBaseNginxProxyDeployment(
    proxyName,
    replicas=2,
    affinity,
    proxyImage,
    deleteLimitOverride=0,
    proxyFlavor="",
  ):: slbbasedeployment.slbBaseDeployment(
    proxyName,
    replicas,
    affinity,
    beforeSharedContainers(proxyImage, deleteLimitOverride, proxyFlavor),
    afterSharedContainers,
    supportedProxies=[proxyName],
    deleteLimitOverride=deleteLimitOverride
) {

    spec+: {
      template+: {
        metadata+: {
          annotations: {
            "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(slbconfigs.nginx.certDirs), " "),
          },
        },
        spec+: {
                 volumes+: std.prune(
                   madkub.madkubSlbCertVolumes(slbconfigs.nginx.certDirs)
                   + madkub.madkubSlbMadkubVolumes() + [
                   slbconfigs.nginx.target_config_volume,
                   slbconfigs.nginx.customer_certs_volume,
                   slbconfigs.nginx.tlsparams_volume,
                 ]
),
                 initContainers: std.prune([
                   madkub.madkubInitContainer(slbconfigs.nginx.certDirs),
                   nginxConfigWipeInitContainer,
                 ]),
                 nodeSelector: { pool: slbconfigs.slbEstate },
               },
      },
    },
  },
}
