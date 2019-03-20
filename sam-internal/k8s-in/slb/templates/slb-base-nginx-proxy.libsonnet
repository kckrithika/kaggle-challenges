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

  local beforeSharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="", slbUpstreamReporterEnabled=true) = [
    slbshared.slbNginxConfig(deleteLimitOverride=deleteLimitOverride, tlsConfigEnabled=true, waitForRealsvrCfg=true),
    slbshared.slbNginxProxy(proxyImage, proxyFlavor, true),
    {
      name: "slb-nginx-data",
      image: slbimages.hyperslb,
      command: [
        "/sdn/slb-nginx-data",
        "--target=" + slbconfigs.nginx.containerTargetDir,
        "--connPort=" + slbports.slb.nginxDataConnPort,
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
    ],
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
  ] + (if slbflights.slbTCPdumpEnabled then [
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
  ] else []),

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

  // In LO3, there are 12 nginx replicas (to circumvent odd rack allocations) and
  // so rolling upgrades take longer.
  // Eventually, we made want to define the maxResourceTimes in slbconfig.jsonnet.
  local maxResourceTime = if configs.estate == "lo3-sam" then "50m0s" else "",

  slbBaseNginxProxyDeployment(
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
    beforeSharedContainers(proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled),
    afterSharedContainers,
    supportedProxies=[proxyName],
    deleteLimitOverride=deleteLimitOverride
) {
    metadata+: std.prune({
      annotations+: utils.fieldIfNonEmpty("autodeployer.sam.data.sfdc.net/maxResourceTime", maxResourceTime, maxResourceTime),
    }),
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
            + madkub.madkubSlbMadkubVolumes()
            + [
              slbconfigs.nginx.target_config_volume,
              slbconfigs.nginx.customer_certs_volume,
              slbconfigs.nginx.tlsparams_volume,
            ]
            + (if slbflights.slbTCPdumpEnabled then
            [configs.config_volume(proxyName)]
            else [])
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
