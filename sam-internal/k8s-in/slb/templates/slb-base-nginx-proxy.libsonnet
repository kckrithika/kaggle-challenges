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

  local beforeSharedContainers(proxyImage, deleteLimitOverride=0) = [
                        slbshared.slbNginxConfig(deleteLimitOverride),
                        slbshared.slbNginxProxy(proxyImage),
                        {
                          name: "slb-nginx-data",
                          image: slbimages.hypersdn,
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
                          image: slbimages.hypersdn,
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
                          ]),
                          env: [
                            slbconfigs.node_name_env,
                          ],
                        },
  ],
local afterSharedContainers = [
                      {
                        name: "slb-cert-deployer",
                        image: slbimages.hypersdn,
                        command: [
                                   "/sdn/slb-cert-deployer",
                                   "--metricsEndpoint=" + configs.funnelVIP,
                                   "--hostnameOverride=$(NODE_NAME)",
                                   "--log_dir=" + slbconfigs.logsDir,
                                   "--custCertsDir=" + slbconfigs.nginx.customerCertsPath,
                                   configs.sfdchosts_arg,
                                 ] + slbconfigs.getNodeApiClientSocketSettings()
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
                        ]),
                        env: [
                          slbconfigs.node_name_env,
                        ],
                      },
],

  slbBaseNginxProxyDeployment(
    proxyName,
    replicas=2,
    affinity,
    proxyImage,
    deleteLimitOverride=0,
  ):: slbbasedeployment.slbBaseDeployment(
    proxyName,
    replicas,
    affinity,
    beforeSharedContainers(proxyImage, deleteLimitOverride),
    afterSharedContainers,
    supportedProxies=[proxyName],
    deleteLimitOverride=deleteLimitOverride) {

    spec+: {
      template+: {
        metadata+: {
          annotations: {
            "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(slbconfigs.nginx.certDirs), " "),
          },
        },
        spec+: {
                 volumes+: configs.filter_empty(
                   madkub.madkubSlbCertVolumes(slbconfigs.nginx.certDirs)
                   + madkub.madkubSlbMadkubVolumes() + [
                   slbconfigs.nginx.target_config_volume,
                   slbconfigs.nginx.customer_certs_volume,
                 ]),
                 initContainers: [
                   madkub.madkubInitContainer(slbconfigs.nginx.certDirs),
                 ],
                 nodeSelector: { pool: slbconfigs.slbEstate },
               },
      },
    },
  },
}
