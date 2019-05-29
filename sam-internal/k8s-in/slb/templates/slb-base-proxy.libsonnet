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
  local utils = import "util_functions.jsonnet",

  local beforeSharedContainers(proxyType, proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled) =
    if proxyType == "envoy" then
    envoyBeforeSharedContainers(proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled) else
    nginxBeforeSharedContainers(proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled),

  local afterSharedContainers(proxyType) =
    if proxyType == "envoy" then
    envoyAfterSharedContainers else
    nginxAfterSharedContainers,

  //local beforeSharedContainersInternal = [],

  //local afterSharedContainersInternal = [],

  local envoyBeforeSharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="", slbUpstreamReporterEnabled=true) = [
    slbshared.slbEnvoyConfig(deleteLimitOverride=deleteLimitOverride),
    slbshared.slbEnvoyProxy(proxyImage, proxyFlavor),
    madkub.madkubRefreshContainer(slbconfigs.envoy.certDirs),
    {
      name: "slb-cert-checker",
      image: slbimages.hyperslb,
      command: [
        "/sdn/slb-cert-checker",
        "--metricsEndpoint=" + configs.funnelVIP,
        "--hostnameOverride=$(NODE_NAME)",
        "--log_dir=" + slbconfigs.logsDir,
        "--server cert name=/server-certs/server/certificates/server.pem",
        "--root cert name=/server-certs/ca.pem",
        configs.sfdchosts_arg,
      ],
      volumeMounts: std.prune(
        madkub.madkubSlbCertVolumeMounts(slbconfigs.envoy.certDirs) + [
          slbconfigs.envoy.target_config_volume_mount,
          slbconfigs.slb_volume_mount,
          slbconfigs.logs_volume_mount,
          configs.sfdchosts_volume_mount,
          slbconfigs.envoy.customer_certs_volume_mount,
        ]
      ),
      env: [
        slbconfigs.node_name_env,
      ],
    },
  ],

  local nginxBeforeSharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="", slbUpstreamReporterEnabled=true) = [
    slbshared.slbNginxConfig(deleteLimitOverride=deleteLimitOverride, tlsConfigEnabled=true, waitForRealsvrCfg=true),
    slbshared.slbNginxProxy(proxyImage, proxyFlavor, true),
    {
      name: "slb-nginx-data",
      image: slbimages.hyperslb,
      command: [
        "/sdn/slb-nginx-data",
        "--target=" + slbconfigs.nginx.containerTargetDir,
        "--connPort=" + slbports.slb.nginxDataConnPort,
        "--log_dir=" + slbconfigs.logsDir,
      ],
      volumeMounts: std.prune([
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
      } + (if slbflights.tamerNginxDataProbes then {
        initialDelaySeconds: 15,
        periodSeconds: 5,
        timeoutSeconds: 10,
      } else {}),
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
      volumeMounts: std.prune(
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
  ] + (if slbUpstreamReporterEnabled then [{
    name: "slb-upstream-status-reporter",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-upstream-status-reporter",
        "--nginxStatusPublishingAddress=$(POD_IP):9999",
        "--log_dir=" + slbconfigs.logsDir,
    ] + (if (slbconfigs.perCluster.upstreamStatusReporterMinPercent[configs.estate] != "") then
        ["--minHealthPercentageForReadiness=" + slbconfigs.perCluster.upstreamStatusReporterMinPercent[configs.estate]]
        else [])
        + (if slbflights.slbNginxReadyPerVip then ["--perVipReadinessCheck=true"] else []),
    volumeMounts: std.prune([
      slbconfigs.logs_volume_mount,
    ]),
    env: [
      slbconfigs.pod_ip_env,
    ],
    readinessProbe: {
      httpGet: {
        path: "/upstreamServerHealth",
        port: 9999,
      },
      initialDelaySeconds: 5,
      periodSeconds: 3,
    },
  }] else []),

  local envoyAfterSharedContainers = [
    {
      name: "slb-cert-deployer",
      image: slbimages.hyperslb,
      command: [
        "/sdn/slb-cert-deployer",
        "--metricsEndpoint=" + configs.funnelVIP,
        "--hostnameOverride=$(NODE_NAME)",
        "--log_dir=" + slbconfigs.logsDir,
        "--custCertsDir=" + slbconfigs.envoy.customerCertsPath,
        "--certfile=/client-certs/client/certificates/client.pem",
        "--keyfile=/client-certs/client/keys/client-key.pem",
        "--cafile=/client-certs/ca.pem",
        configs.sfdchosts_arg,
      ]
      + slbconfigs.getNodeApiClientSocketSettings()
      + [
        slbconfigs.envoy.reloadSentinelParam,
      ],
      volumeMounts: std.prune(
        madkub.madkubSlbCertVolumeMounts(slbconfigs.envoy.certDirs) + [
          slbconfigs.envoy.target_config_volume_mount,
          slbconfigs.envoy.customer_certs_volume_mount,
          slbconfigs.slb_volume_mount,
          slbconfigs.logs_volume_mount,
          configs.sfdchosts_volume_mount,
        ]
      ),
      env: [
        slbconfigs.node_name_env,
      ],
    },
//    {
//      image: slbimages.hyperslb,
//      command: [
//          "/sdn/slb-tcpdump",
//          "--tcpdump.pollinterval=15m",
//      ],
//      name: "slb-tcpdump",
//      resources: {
//          requests: {
//              cpu: "0.5",
//              memory: "300Mi",
//          },
//          limits: {
//              cpu: "0.5",
//              memory: "300Mi",
//          },
//      },
//      volumeMounts: [
//        configs.config_volume_mount,
//      ],
//    },
  ],

  local nginxAfterSharedContainers = [
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
      ]
      + slbconfigs.getNodeApiClientSocketSettings()
      + [
        slbconfigs.nginx.reloadSentinelParam,
      ],
      volumeMounts: std.prune(
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
    {
      image: slbimages.hyperslb,
      command: [
          "/sdn/slb-tcpdump",
          "--tcpdump.pollinterval=15m",
      ],
      name: "slb-tcpdump",
      resources: {
          requests: {
              cpu: "0.5",
              memory: "300Mi",
          },
          limits: {
              cpu: "0.5",
              memory: "300Mi",
          },
      },
      volumeMounts: [
        configs.config_volume_mount,
      ],
    },
  ],

  local configWipeInitContainer(proxyType="") = {
    local proxyconfigs = if proxyType == "envoy" then slbconfigs.envoy else slbconfigs.nginx,
    local imageName = if proxyType == "envoy" then "slb-envoy-config-wipe" else "slb-nginx-config-wipe",
    assert std.length(proxyconfigs.containerTargetDir) > 0 :
    "Invalid configuration: slbconfigs.%s.containerTargetDir is empty" % proxyType,
    name: if slbflights.renameConfigWipe then "slb-config-wipe" else imageName,
    image: slbimages.hyperslb,
    command: [
      "/bin/bash",
      "-xec",
      "rm -rf %s/*" % [proxyconfigs.containerTargetDir],
    ],
    volumeMounts: [
      proxyconfigs.target_config_volume_mount,
    ],
  },

  slbBaseProxyDeployment(
    proxyType,
    proxyName,
    replicas=2,
    affinity,
    proxyImage,
    deleteLimitOverride=0,
    proxyFlavor="",
    slbUpstreamReporterEnabled=true,
  ):: slbbasedeployment.slbBaseDeployment(
    proxyName,
    replicas,
    affinity,
    beforeSharedContainers(proxyType, proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled),
    afterSharedContainers(proxyType),
    supportedProxies=[proxyName],
    deleteLimitOverride=deleteLimitOverride
) {
    local validTypes = ["envoy", "nginx"],
    assert (proxyType == "envoy" || proxyType == "nginx") :
    'proxyType "%s" is invalid, must be one of %s' % [proxyType, validTypes],
    local proxyconfigs = if proxyType == "envoy" then slbconfigs.envoy else slbconfigs.nginx,
    metadata+: std.prune({
      annotations+: utils.fieldIfNonEmpty("autodeployer.sam.data.sfdc.net/maxResourceTime", slbconfigs.maxResourceTime, slbconfigs.maxResourceTime),
    }),
    spec+: {
      template+: {
        metadata+: {
          annotations: {
            "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(proxyconfigs.certDirs), " "),
          },
        },
        spec+: {
          volumes+: std.prune(
            madkub.madkubSlbCertVolumes(proxyconfigs.certDirs)
            + madkub.madkubSlbMadkubVolumes()
            + [
              proxyconfigs.target_config_volume,
              proxyconfigs.customer_certs_volume,
              proxyconfigs.tlsparams_volume,
              if proxyType == "nginx" then configs.config_volume(proxyName),
            ]
          ),
          [if proxyType == "envoy" then "securityContext"]: { fsGroup: 7447 },
          initContainers: std.prune([
            madkub.madkubInitContainer(proxyconfigs.certDirs),
            configWipeInitContainer(proxyType),
          ]),
          nodeSelector: { pool: slbconfigs.slbEstate },
        },
      },
    },
  },
}
