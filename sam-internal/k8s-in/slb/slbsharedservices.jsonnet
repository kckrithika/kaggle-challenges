{
  dirSuffix:: "",
  local portconfigs = import "slbports.jsonnet",
  local configs = import "config.jsonnet",
  local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
  local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile },
  local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },
  local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: $.dirSuffix },

  local configProcSentinel = slbconfigs.configDir + "/slb-config-proc.sentinel",
  local mwSentinel = slbconfigs.configDir + "/slb-manifest-watcher.sentinel",
  local realsvrCfgSentinel = slbconfigs.configDir + "/slb-realsvrcfg.sentinel",

  slbConfigProcessor(
    configProcessorLivenessPort,
    proxyLabelSelector="slb-nginx-config-b",
    servicesToLbOverride="",
    servicesNotToLbOverride="illumio-proxy-svc,illumio-dsr-nonhost-svc,illumio-dsr-host-svc",
    supportedProxies=[],
    includeProxyConfigurationVolume=true,
    includeSlbPortalOverride=false,
    vipLocationName="",
    pseudoApiServer="",
  ): {
    name: "slb-config-processor",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-config-processor",
      "--configDir=" + slbconfigs.configDir,
    ]
    + (if configs.estate == "prd-sdc" then ["--period=1200s"] else ["--period=1800s"])
    + [
      "--vipsToAcl=" + slbconfigs.vipsToAcl,
      "--podPhaseCheck=true",
      "--namespace=" + slbconfigs.namespace,
      "--podstatus=running",
      "--subnet=" + slbconfigs.subnet,
      "--k8sapiserver=",
      "--serviceList=" + slbconfigs.serviceList,
      "--useVipLabelToSelectSvcs=" + slbconfigs.useVipLabelToSelectSvcs,
      "--metricsEndpoint=" + configs.funnelVIP,
      "--log_dir=" + slbconfigs.logsDir,
      "--sleepTime=100ms",
      "--livenessProbePort=" + configProcessorLivenessPort,
      "--shouldRemoveConfig=true",
      configs.sfdchosts_arg,
      "--proxySelectorLabelValue=" + proxyLabelSelector,
      "--hostnameOverride=$(NODE_NAME)",
    ] + (if configs.estate == "prd-sam" then [
      "--servicesToLbOverride=" + servicesToLbOverride,
      "--servicesNotToLbOverride=" + servicesNotToLbOverride,
    ] else [])
    + [
      "--control.configProcSentinel=" + configProcSentinel,
    ] + (if std.length(supportedProxies) > 0 then [
      "--pipeline.supportedProxies=" + std.join(",", supportedProxies),
    ] else [])
    + (if configs.estate == "vpod" then [
      "--vipdnsoptions.slbdomain=t.force.com",
    ] else [])
    + (if includeSlbPortalOverride then [
      "--vipdnsoptions.viplocation=" + vipLocationName,
      "--k8sapiserver=" + pseudoApiServer,
    ] else []),
    volumeMounts: std.prune([
      configs.maddog_cert_volume_mount,
      slbconfigs.slb_volume_mount,
      slbconfigs.slb_config_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.cert_volume_mount,
      configs.kube_config_volume_mount,
      configs.sfdchosts_volume_mount,
      (if includeProxyConfigurationVolume then slbconfigs.proxyconfig_volume_mount else {}),
    ]),
    env: [
      configs.kube_config_env,
      slbconfigs.node_name_env,
    ],
    securityContext: {
      privileged: true,
    },
    livenessProbe: {
      httpGet: {
        path: "/liveness-probe",
        port: configProcessorLivenessPort,
      },
      initialDelaySeconds: 600,
      timeoutSeconds: 5,
      periodSeconds: 30,
    },
  },
  slbNodeApi(nodeApiPort, mwSentinelNeedsCheck):: {
    name: "slb-node-api",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-node-api",
      "--port=" + nodeApiPort,
      "--configDir=" + slbconfigs.configDir,
      "--log_dir=" + slbconfigs.logsDir,
      "--netInterface=lo",
      "--checkSentinel=true",
      "--control.configProcSentinel=" + configProcSentinel,
      "--control.sentinelExpiration=1800s",  # config processor's interval
    ]
    + slbconfigs.getNodeApiServerSocketSettings()
    + [
      "--checkMwSentinel=" + mwSentinelNeedsCheck,
      "--control.manifestWatcherSentinel=" + mwSentinel,
    ],
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      slbconfigs.logs_volume_mount,
    ] + (if slbimages.phaseNum <= 1 || configs.estate == "prd-samtwo" then [slbconfigs.slb_config_volume_mount] else [])),
  },
  slbCleanupConfig: {
    name: "slb-cleanup-config-processor",
    image: slbimages.hyperslb,
    command:
    [
      "/sdn/slb-cleanup",
      "--period=1800s",
      "--logsMaxAge=1h",
      "--filesDirToCleanup=" + slbconfigs.configDir,
      "--shouldSkipServiceRecords=true",
      "--log_dir=" + slbconfigs.logsDir,
      "--shouldSkipSlbBlock=true",
      "--skipFilesWithSuffix=.sock",
    ] + (if configs.estate == "prd-sam" then [
        "--shouldNotDeleteAllFiles=false",
    ] else [
        "--shouldNotDeleteAllFiles=true",
        "--maxDeleteFileCount=20",
    ]),
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      slbconfigs.slb_config_volume_mount,
      slbconfigs.logs_volume_mount,
    ]),
    securityContext: {
      privileged: true,
    },
  },
  slbRealSvrCfg(nodeApiPort, nginxPodMode, deleteLimitOverride=0):: {
    name: "slb-realsvrcfg",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-realsvrcfg",
      "--configDir=" + slbconfigs.configDir,
      "--period=5s",
      "--netInterfaceName=eth0",
      "--log_dir=" + slbconfigs.logsDir,
      "--client.serverPort=" + nodeApiPort,
      "--client.serverInterface=lo",
      "--control.realsvrCfgSentinel=" + realsvrCfgSentinel,
    ]
    + (if $.dirSuffix == "slb-nginx-config-b" then [
      "--control.sentinelExpiration=1200s",
    ] else [])
    + [
      "--nginxPodMode=" + nginxPodMode,
    ]
    + slbconfigs.getNodeApiClientSocketSettings()
    + ["--maxDeleteVipCount=" + slbconfigs.maxDeleteLimit(deleteLimitOverride)],
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      slbconfigs.sbin_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
    ]),
    securityContext: {
      privileged: true,
    },
  },
  slbFileWatcher: {
    name: "slb-file-watcher",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-file-watcher",
      "--filePath=/host/data/slb/logs/" + $.dirSuffix + "/slb-nginx-proxy.emerg.log",
      "--metricName=nginx-emergency",
      "--lastModReportTime=120s",
      "--scanPeriod=10s",
      "--skipZeroLengthFiles=true",
      "--metricsEndpoint=" + configs.funnelVIP,
      "--log_dir=" + slbconfigs.logsDir,
      "--hostnameOverride=$(NODE_NAME)",
      configs.sfdchosts_arg,
    ],
    env: [
      slbconfigs.node_name_env,
    ],
    volumeMounts: std.prune([
      {
        name: "var-target-config-volume",
        mountPath: "/etc/nginx/conf.d",
      },
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
    ]),
  },
  slbIfaceProcessor(nodeApiPort, deleteLimitOverride=0): {
    name: "slb-iface-processor",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-iface-processor",
      "--configDir=" + slbconfigs.configDir,
      "--control.sentinelExpiration=300s",
      "--period=5s",
      "--metricsEndpoint=" + configs.funnelVIP,
      "--log_dir=" + slbconfigs.logsDir,
      configs.sfdchosts_arg,
      "--subnet=" + slbconfigs.subnet + "," + slbconfigs.publicSubnet,
    ],
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      slbconfigs.slb_config_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
      slbconfigs.sbin_volume_mount,
    ]),
    securityContext: {
      privileged: true,
    },
  },
  slbManifestWatcher(supportedProxies=[], deleteLimitOverride=0, includeSlbPortalOverride=false, vipLocationName=""): {
    name: "slb-manifest-watcher",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-manifest-watcher",
      "--manifestOutputDir=" + slbconfigs.manifestDir,
      "--tnrpEndpoint=" + configs.tnrpEndpoint,
      "--hostnameOverride=$(NODE_NAME)",
      "--log_dir=" + slbconfigs.logsDir,
      configs.sfdchosts_arg,
    ] + slbconfigs.getNodeApiClientSocketSettings()
    + ["--maxDeleteLimit=" + slbconfigs.maxDeleteLimit(400)]
    + (if slbflights.roleEnabled then [
      "--isRoleUsed=true",
    ] else [])
    + (if slbimages.phaseNum <= 1
    then
    [
          "--metricsEndpoint=" + configs.funnelVIP,
          "--vcioptions.strict=false",
          "--client.allowStale=true",
          "--control.manifestWatcherSentinel=" + mwSentinel,
    ]
    else
    [
      "--metricsEndpoint=" + configs.funnelVIP,
      "--vcioptions.strict=true",
      "--client.allowStale=true",
      "--control.manifestWatcherSentinel=" + mwSentinel,
    ]) + (if std.length(supportedProxies) > 0 then [
      "--pipeline.supportedProxies=" + std.join(",", supportedProxies),
    ] else [])
    + (if includeSlbPortalOverride then [
      "--vipdnsoptions.viplocation=" + vipLocationName,
    ] else []),
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      configs.sfdchosts_volume_mount,
      configs.kube_config_volume_mount,
      configs.maddog_cert_volume_mount,
      slbconfigs.proxyconfig_volume_mount,
    ]),
    env: [
      configs.kube_config_env,
      slbconfigs.node_name_env,
    ],
    securityContext: {
      privileged: true,
    },
  },
  slbLogCleanup: {
    name: "slb-cleanup",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-cleanup",
      "--period=1800s",
      "--logsMaxAge=48h",
      "--log_dir=" + slbconfigs.cleanupLogsDir,
      "--filesDirToCleanup=" + slbconfigs.logsDir,
      "--shouldSkipServiceRecords=false",
      "--shouldNotDeleteAllFiles=false",
    ],
    volumeMounts: std.prune([
      slbconfigs.slb_volume_mount,
      slbconfigs.slb_config_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
      slbconfigs.cleanup_logs_volume_mount,
    ]),
    env: [
      configs.kube_config_env,
    ],
    securityContext: {
      privileged: true,
    },
  } + (if configs.estate == "prd-sdc" then {
    livenessProbe: {
        exec: {
            command: [
                "test",
                "`find /slb-cleanup-heartbeat -mmin -.5`",
            ],
        },
        initialDelaySeconds: 15,
        periodSeconds: 15,
    },
  } else {}),
  slbNginxConfig(deleteLimitOverride=0, vipInterfaceName="", tlsConfigEnabled=false, waitForRealsvrCfg=false): {
    // TODO this can likely be deleted
    // TODO https://computecloud.slack.com/archives/G340CE86R/p1558639955057700
    ports: [
      {
        name: "slb-nginx-port",
        containerPort: portconfigs.slb.slbNginxControlPort,
      },
    ],
    name: "slb-nginx-config",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-nginx-config",
      "--target=" + slbconfigs.nginx.containerTargetDir,
      "--netInterfaceName=eth0",
      "--metricsEndpoint=" + configs.funnelVIP,
      "--log_dir=" + slbconfigs.logsDir,
      "--maxDeleteServiceCount=" + std.max((if configs.kingdom == "xrd" then 150 else 0), slbconfigs.maxDeleteLimit(deleteLimitOverride)),
      configs.sfdchosts_arg,
      "--client.serverInterface=lo",
      "--hostnameOverride=$(NODE_NAME)",
      "--httpconfig.trustedProxies=" + slbconfigs.perCluster.trustedProxies[configs.estate],
      "--iprange.InternalIpRange=" + slbconfigs.perCluster.internalIpRange[configs.estate],
    ] + (if waitForRealsvrCfg then [
      "--control.realsvrCfgSentinel=" + realsvrCfgSentinel,
      "--control.sentinelExpiration=60s",
      "--featureflagWaitForRealsvrCfg=true",
    ] else [])
    + slbconfigs.getNodeApiClientSocketSettings()
    + [
      slbconfigs.nginx.reloadSentinelParam,
      "--httpconfig.custCertsDir=" + slbconfigs.nginx.customerCertsPath,
      "--checkDuplicateVips=true",
      "--httpconfig.accessLogFormat=main",
      "--commonconfig.riseCount=5",
      "--commonconfig.fallCount=2",
      "--commonconfig.healthTimeout=3000",
    ] + (if std.length(vipInterfaceName) > 0 then [
      # The default vip interface name is tunl0
      "--vipInterfaceName=" + vipInterfaceName,
    ] else [])
    + [slbconfigs.nginx.configUpdateSentinelParam]
    + (if tlsConfigEnabled then [
      "--httpconfig.tlsConfigEnabled=true",
      "--httpconfig.allowedCiphers=ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA",
      "--httpconfig.allowedEcdhCurves=secp521r1:secp384r1:prime256v1",
      "--httpconfig.dhParamsFile=/tlsparams/dhparams.pem",
    ] else [])
    + [
      "--commonconfig.accessLogDirectory=" + slbconfigs.logsDir,
      "--tcpconfig.accessLogFormat=basic",
      "--httpconfig.accessLogDirectory=" + slbconfigs.logsDir,
    ],
    volumeMounts: std.prune([
      slbconfigs.nginx.target_config_volume_mount,
      slbconfigs.slb_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
      if tlsConfigEnabled then slbconfigs.nginx.tlsparams_volume_mount else {},
    ]),
    securityContext: {
      privileged: true,
    },
    env: [
      slbconfigs.node_name_env,
      configs.kube_config_env,
    ],
  } + configs.ipAddressResourceRequest,
  slbNginxProxy(proxyImage, proxyFlavor="", tlsConfigEnabled=false): {
    name: "slb-nginx-proxy",
    image: proxyImage,
    env: [
      {
        name: "KINGDOM",
        value: configs.kingdom,
      },
    ] + (if proxyFlavor != "" then [{ name: "PROXY_FLAVOR", value: proxyFlavor }] else []),
    command: [
      "/runner.sh",
      slbconfigs.logsDir,
      slbconfigs.nginx.configUpdateSentinelPath,
    ],
    livenessProbe: {
      httpGet: {
        path: "/",
        port: portconfigs.slb.slbNginxProxyLivenessProbePort,
      },
      initialDelaySeconds: 15,
      periodSeconds: 10,
    },
    volumeMounts: std.prune([
      slbconfigs.nginx.nginx_config_volume_mount,
      slbconfigs.logs_volume_mount,
      slbconfigs.nginx.customer_certs_volume_mount,
    ]
    + madkub.madkubSlbCertVolumeMounts(slbconfigs.nginx.certDirs)
    + [
      slbconfigs.slb_volume_mount,
      if tlsConfigEnabled then slbconfigs.nginx.tlsparams_volume_mount else {},
      if proxyFlavor == "hsm" then slbconfigs.kmsconfig_volume_mount else {},
    ]),
    readinessProbe: {
      httpGet: {
        path: "/",
        port: portconfigs.slb.slbNginxProxyLivenessProbePort,
      },
      initialDelaySeconds: 2,
      periodSeconds: 5,
      successThreshold: 4,
    },
  },
  slbEnvoyConfig(deleteLimitOverride=0, vipInterfaceName=""): {
    name: "slb-envoy-config",
    image: slbimages.hyperslb,
    command: [
      "/sdn/slb-envoy-config",
      "--cdsconfig.healthyCount=5",
      "--cdsconfig.unhealthyCount=2",
      "--cdsconfig.healthTimeout=3s",
      "--cdsconfig.healthCheckInterval=3s",
      "--client.serverInterface=lo",
      "--commonoptions.metricsendpoint=" + configs.funnelVIP,
      "--commonoptions.hostname=$(NODE_NAME)",
      "--control.realsvrCfgSentinel=" + realsvrCfgSentinel,
      "--control.sentinelExpiration=60s",
      "--envoyNodeID=%s.$(FUNCTION_NAMESPACE).$(FUNCTION_INSTANCE_NAME)" % [slbconfigs.envoyProxyConfigDeploymentName],
      "--envoyNodeNamespace=$(FUNCTION_NAMESPACE)",
      "--heartbeat.defaultdecayduration=5m",
      "--iprange.InternalIpRange=" + slbconfigs.perCluster.internalIpRange[configs.estate],
      "--livenessProbePort=8080",
      "--log_dir=" + slbconfigs.logsDir,
      "--netInterfaceName=eth0",
      "--target=" + slbconfigs.envoy.containerTargetDir,
      "--tlsconfig.allowedCiphers=%s" % [
        std.join(":", [
          "ECDHE-ECDSA-AES256-GCM-SHA384",  // envoy (BoringSSL) supports a narrower set of ciphers than nginx (OpenSSL).
          "ECDHE-RSA-AES256-GCM-SHA384",
          "ECDHE-ECDSA-AES128-GCM-SHA256",
          "ECDHE-RSA-AES128-GCM-SHA256",
          "AES256-GCM-SHA384",
          "AES128-GCM-SHA256",
          "AES256-SHA",
        ]),
      ],
      "--tlsconfig.allowedEcdhCurves=P-256",  // P-256 is the same as secp256r1, see https://www.ietf.org/rfc/rfc5480.txt. Envoy only knows it by P-256 though.
      "--tlsconfig.custCertsDir=" + slbconfigs.envoy.customerCertsPath,
      "--tlsconfig.certsDir=/server-certs/server/certificates",
      "--tlsconfig.keysDir=/server-certs/server/keys",
      "--tlsconfig.caFile=/server-certs/ca.pem",
      "--tlsconfig.clientCertsDir=/client-certs/client/certificates",
      "--tlsconfig.clientKeysDir=/client-certs/client/keys",
      "--tlsconfig.clientCAFile=/client-certs/ca.pem",
      configs.sfdchosts_arg,

//        "--maxDeleteServiceCount=" + std.max((if configs.kingdom == "xrd" then 150 else 0), slbconfigs.maxDeleteLimit(deleteLimitOverride)),
//        "--httpconfig.trustedProxies=" + slbconfigs.perCluster.trustedProxies[configs.estate],
//        "--iprange.InternalIpRange=" + slbconfigs.perCluster.internalIpRange[configs.estate],
    ]
    + slbconfigs.getNodeApiClientSocketSettings()
    + [
//        slbconfigs.envoy.reloadSentinelParam,
//        slbconfigs.envoy.configUpdateSentinelParam,
//        "--httpconfig.accessLogFormat=main",
    ] + (if std.length(vipInterfaceName) > 0 then [
      # The default vip interface name is tunl0
      "--vipInterfaceName=" + vipInterfaceName,
    ] else []),
    volumeMounts: std.prune([
      slbconfigs.envoy.target_config_volume_mount,
      slbconfigs.slb_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.sfdchosts_volume_mount,
    ]),
    env: [
      slbconfigs.node_name_env,
      slbconfigs.function_namespace_env,
      slbconfigs.function_instance_name_env,
      configs.kube_config_env,
    ],
  } + configs.ipAddressResourceRequest,
  slbEnvoyProxy(proxyImage, proxyFlavor=""): {
    name: "slb-envoy-proxy",
    image: proxyImage,
    env: [
      {
        name: "KINGDOM",
        value: configs.kingdom,
      },
    ] + (if proxyFlavor != "" then [{ name: "PROXY_FLAVOR", value: proxyFlavor }] else []),
//      command: [
//        "/runner.sh",
//        slbconfigs.logsDir,
//        slbconfigs.envoy.configUpdateSentinelPath,
//      ],
    command: [
      "/home/sfdc-sherpa/hot_restarter",
      "/home/sfdc-sherpa/bin/runner.sh",
      slbconfigs.envoy.containerTargetDir + "/envoy-bootstrap.yaml",
      slbconfigs.envoy.reloadSentinelPath,
    ],
    livenessProbe: {
      httpGet: {
        path: "/liveness-probe",
        // TODO Bring up a liveness port on Envoy
        // (8080 is currently associated with slb-proxy-config)
        // TODO Also create a variable for this port
        port: 8080,
        //port: portconfigs.slb.slbNginxProxyLivenessProbePort,
      },
      initialDelaySeconds: 15,
      periodSeconds: 10,
    },
    readinessProbe: {
      httpGet: {
        path: "/liveness-probe",
        // TODO Bring up a liveness port on Envoy
        // (8080 is currently associated with slb-proxy-config)
        // TODO Also create a variable for this port
        port: 8080,
        //port: portconfigs.slb.slbNginxProxyLivenessProbePort,
      },
      initialDelaySeconds: 2,
      periodSeconds: 5,
      successThreshold: 4,
    },
    # Add the [CAP_]NET_BIND_SERVICE capability so that envoy running as a
    # low-privileged user can bind to privileged ports.
    securityContext: {
      capabilities: {
        add: [
          "NET_BIND_SERVICE",
        ],
      },
    },
    volumeMounts: std.prune([
      slbconfigs.logs_volume_mount,
      slbconfigs.envoy.customer_certs_volume_mount,
      slbconfigs.slb_volume_mount,
    ]
    + madkub.madkubSlbCertVolumeMounts(slbconfigs.envoy.certDirs)),
  },
  slbUnknownPodCleanup(name, namespace): {
    name: "slb-cleanup-unknownpods" + name,
    image: slbimages.hyperslb,
    command: [
      "/bin/bash",
      "/sdn/slb-cleanup-stuckpods.sh",
    ] + (if namespace != "" then [namespace] else []),
    volumeMounts: std.prune([
      configs.maddog_cert_volume_mount,
      slbconfigs.slb_volume_mount,
      slbconfigs.slb_config_volume_mount,
      slbconfigs.logs_volume_mount,
      configs.cert_volume_mount,
      configs.opsadhoc_volume_mount,
      configs.kube_config_volume_mount,
      {
        name: "kubectl",
        mountPath: "/usr/bin/kubectl",
      },
    ]),
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
}
