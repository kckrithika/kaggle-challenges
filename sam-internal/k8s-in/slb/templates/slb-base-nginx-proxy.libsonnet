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

  local certDirs = ["cert1", "cert2"],
  local nginxHostTargetDir = slbconfigs.slb_volume.hostPath.path + "/" + $.dirSuffix + "/config",
  local nginxContainerTargetDir = slbconfigs.slb_volume_mount.mountPath + "/" + $.dirSuffix + "/config",
  local nginxReloadSentinelParam = "--control.nginxReloadSentinel=" + nginxContainerTargetDir + "/nginx.marker",
  local target_config_volume = {
     name: "var-target-config-volume",
     hostPath: {
        path: nginxHostTargetDir,
     },
  },
  local target_config_volume_mount = {
     name: "var-target-config-volume",
     mountPath: nginxContainerTargetDir,
  },
  local customer_certs_volume_mount = {
    name: "customer-certs",
    mountPath: slbconfigs.customerCertsPath,
  },
  local nginx_config_volume_mount = {
    name: "var-target-config-volume",
    mountPath: "/etc/nginx/conf.d",
  },
  local maxDeleteLimit(deleteLimitOverride) = (if configs.kingdom == "xrd" then "150"
    else if deleteLimitOverride > 0 then deleteLimitOverride
    else slbconfigs.perCluster.maxDeleteCount[configs.estate]),

  local beforeSharedContainers(proxyImage, deleteLimitOverride=0) = [
     {
                          ports: [
                            {
                              name: "slb-nginx-port",
                              containerPort: portconfigs.slb.slbNginxControlPort,
                            },
                          ],
                          name: "slb-nginx-config",
                          image: slbimages.hypersdn,
                          [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                          command: [
                                     "/sdn/slb-nginx-config",
                                     "--target=" + nginxContainerTargetDir,
                                     "--netInterfaceName=eth0",
                                     "--metricsEndpoint=" + configs.funnelVIP,
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--maxDeleteServiceCount=" + maxDeleteLimit(deleteLimitOverride),
                                     configs.sfdchosts_arg,
                                     "--client.serverInterface=lo",
                                     "--hostnameOverride=$(NODE_NAME)",
                                     "--httpconfig.trustedProxies=" + slbconfigs.perCluster.trustedProxies[configs.estate],
                                   ]
                                   + slbconfigs.getNodeApiClientSocketSettings()
                                   + [
                                     nginxReloadSentinelParam,
                                     "--httpconfig.custCertsDir=" + slbconfigs.customerCertsPath,
                                     "--checkDuplicateVips=true",
                                   ] + (if slbflights.newAccessLogFormat then [
                                     "--httpconfig.accessLogFormat=main",
                                   ] else [])
                                   + (if slbflights.syncHealthConfigEnabled then [
                                     "--commonconfig.riseCount=5",
                                     "--commonconfig.fallCount=2",
                                     "--commonconfig.healthTimeout=3000",
                                   ] else []),
                          volumeMounts: configs.filter_empty([
                            target_config_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                          ]),
                          securityContext: {
                            privileged: true,
                          },
                          env: [
                            {
                              name: "NODE_NAME",
                              valueFrom: {
                                fieldRef: {
                                  fieldPath: "spec.nodeName",
                                },
                              },
                            },
                            configs.kube_config_env,
                          ],
                        },
                        {
                          name: "slb-nginx-proxy",
                          image: proxyImage,
                          env: [
                              {
                                 name: "KINGDOM",
                                 value: configs.kingdom,
                              },
                          ],
                          command: ["/runner.sh"],
                          livenessProbe: {
                            httpGet: {
                              path: "/",
                              port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                            },
                            initialDelaySeconds: 15,
                            periodSeconds: 10,
                          },
                          volumeMounts: configs.filter_empty([
                            nginx_config_volume_mount,
                            slbconfigs.nginx_logs_volume_mount,
                            customer_certs_volume_mount
                          ]
                          + madkub.madkubSlbCertVolumeMounts(certDirs)
                          + if slbflights.nginxSlbVolumeMount then [
                            slbconfigs.slb_volume_mount,
                          ] else []),
                        } + (if slbflights.nginxReadinessProbeEnabled then {
                          readinessProbe: {
                            httpGet: {
                              path: "/",
                              port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                            },
                            initialDelaySeconds: 2,
                            periodSeconds: 5,
                            successThreshold: 4,
                          }
                        } else {}),
                        {
                          name: "slb-nginx-data",
                          image: slbimages.hypersdn,
                          command: [
                            "/sdn/slb-nginx-data",
                            "--target=" + nginxContainerTargetDir,
                            "--connPort=" + slbports.slb.nginxDataConnPort,
                          ],
                          volumeMounts: configs.filter_empty([
                            target_config_volume_mount,
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
                        madkub.madkubRefreshContainer(certDirs),
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
                            madkub.madkubSlbCertVolumeMounts(certDirs) + [
                            target_config_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                            customer_certs_volume_mount,
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
                                   "--custCertsDir=" + slbconfigs.customerCertsPath,
                                   configs.sfdchosts_arg,
                                 ] + slbconfigs.getNodeApiClientSocketSettings()
                                 + [
                                   nginxReloadSentinelParam,
                                 ],
                        volumeMounts: configs.filter_empty(
                          madkub.madkubSlbCertVolumeMounts(certDirs) + [
                          target_config_volume_mount,
                          customer_certs_volume_mount,
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
            "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
          },
        },
        spec+: {
                 volumes+: configs.filter_empty(
                   madkub.madkubSlbCertVolumes(certDirs)
                   + madkub.madkubSlbMadkubVolumes() + [
                   target_config_volume,
                   {
                     emptyDir: {
                       medium: "Memory",
                     },
                     name: "customer-certs",
                   },
                 ]),
                 initContainers: [
                   madkub.madkubInitContainer(certDirs),
                 ],
                 nodeSelector: { pool: slbconfigs.slbEstate },
               },
      },
    },
  },
}
