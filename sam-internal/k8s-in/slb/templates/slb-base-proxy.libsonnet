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

  // *** NOTE ***
  // The functions within this library contain conditionals that inspect a variable
  // capturing the type of proxy being deployed.
  // As of this writing, the supported values are "envoy" and "nginx".
  //
  // slbBaseProxyDeployment(...) is the entry point for proxy deployment; other functions with
  // conditionals based on proxy type are downstream of slbBaseProxyDeployment(...).
  //
  // Thus, slbBaseProxyDeployment(...) is THE ONLY PLACE where the proxy type is validated.
  // Downstream, we do things like `if proxyType == "envoy" then envoyStuff() else nginxStuff()`.
  // In other words, we assume if it's not envoy, it's nginx.  The introduction of additional
  // proxy implementations will require updates to the single assertion and multiple conditionals.

  local beforeSharedContainers(proxyType, proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled) =
      (
if proxyType == "envoy" then
        envoySharedContainers(proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled)
      else
        nginxSharedContainers(proxyImage, deleteLimitOverride, proxyFlavor, slbUpstreamReporterEnabled)
      ),

  local envoySharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="", slbUpstreamReporterEnabled=true) = [
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
        slbconfigs.envoy.reloadSentinelParam,
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
    {
      image: slbimages.hyperslb,
      command: [
          "/sdn/slb-tcpdump",
          "--tcpdump.pollinterval=15m",
          "--tcpdump.filepath=%s/tcpdumpcommand.json" % slbconfigs.tcpdump_volume_mount.mountPath,
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
        slbconfigs.tcpdump_volume_mount,
      ],
    },
  ],

  local nginxSharedContainers(proxyImage, deleteLimitOverride=0, proxyFlavor="", slbUpstreamReporterEnabled=true) = [
    slbshared.slbNginxConfig(deleteLimitOverride=deleteLimitOverride, tlsConfigEnabled=true, waitForRealsvrCfg=true, proxyFlavor=proxyFlavor),
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
        initialDelaySeconds: 15,
        periodSeconds: 5,
        timeoutSeconds: 10,
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
        ## TODO ##
        # slb-cert-checker is currently using the default path for the reload sentinel ("/host/data/slb/nginx.reload"),
        # which is incorrect. For nginx there are reloads induced often enough by other events (deployments, canary VIP
        # creation/update/deletion) that this isn't impactful.
        #
        # slbconfigs.nginx.reloadSentinelParam,
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
      + ["--perVipReadinessCheck=true"],
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
  }] else []) + [
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
          "--tcpdump.filepath=%s/tcpdumpcommand.json" % slbconfigs.tcpdump_volume_mount.mountPath,
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
        slbconfigs.tcpdump_volume_mount,
      ],
    },
  ],

  local configWipeInitContainer(proxyconfigs) = {
    assert std.length(proxyconfigs.containerTargetDir) > 0 :
      "Invalid configuration: proxyconfigs.containerTargetDir is empty",
    name: "slb-config-wipe",
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
    afterSharedContainers=[],
    supportedProxies=[proxyName],
    deleteLimitOverride=deleteLimitOverride
) {
    local validTypes = std.set(["envoy", "nginx"]),
    assert std.setMember(proxyType, validTypes) :
      'proxyType "%s" is invalid, must be one of %s' % [proxyType, validTypes],
    local proxyconfigs = if proxyType == "envoy" then slbconfigs.envoy else slbconfigs.nginx,
    metadata+: std.prune({
      annotations+: utils.fieldIfNonEmpty("autodeployer.sam.data.sfdc.net/maxResourceTime", proxyconfigs.maxResourceTime, proxyconfigs.maxResourceTime),
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
              slbconfigs.tcpdump_volume(proxyName),
            ]
          ),
          initContainers: std.prune([
            madkub.madkubInitContainer(proxyconfigs.certDirs),
            configWipeInitContainer(proxyconfigs),
          ]),
          nodeSelector: { pool: slbconfigs.slbEstate },
        } + proxyconfigs.pod_security_context,
      },
    },
  },
}
