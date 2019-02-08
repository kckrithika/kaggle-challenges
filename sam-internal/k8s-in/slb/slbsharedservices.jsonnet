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

    slbConfigProcessor(
      configProcessorLivenessPort,
      proxyLabelSelector="slb-nginx-config-b",
      servicesToLbOverride="",
      servicesNotToLbOverride="illumio-proxy-svc,illumio-dsr-nonhost-svc,illumio-dsr-host-svc",
      supportedProxies=[],
      includeProxyConfigurationVolume=true,
): {
        name: "slb-config-processor",
        image: slbimages.hyperslb,
        command: [
                     "/sdn/slb-config-processor",
                     "--configDir=" + slbconfigs.configDir,
                 ] + (
                     if configs.estate == "prd-sdc" then [
                         "--period=1200s",
                     ] else [
                         "--period=1800s",
                     ]
                 ) + [
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
                      ] else []) +
                 [
                     "--control.configProcSentinel=" + configProcSentinel,
                 ] + (if std.length(supportedProxies) > 0 then [
                        "--pipeline.supportedProxies=" + std.join(",", supportedProxies),
                    ] else [])
                   + (if configs.estate == "vpod" then [
                        "--vipdnsoptions.slbdomain=t.force.com",
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
                                           ]
                                           + if slbimages.phaseNum <= 1 || configs.estate == "prd-samtwo" then [slbconfigs.slb_config_volume_mount] else []),
    },
    slbCleanupConfig: {
        name: "slb-cleanup-config-processor",
        image: slbimages.hyperslb,
        command: [
                     "/sdn/slb-cleanup",
                     "--period=1800s",
                     "--logsMaxAge=1h",
                     "--filesDirToCleanup=" + slbconfigs.configDir,
                     "--shouldSkipServiceRecords=true",
                     "--shouldNotDeleteAllFiles=true",
                     "--log_dir=" + slbconfigs.logsDir,
                     "--shouldSkipSlbBlock=true",
                     "--skipFilesWithSuffix=.sock",
                     "--maxDeleteFileCount=20",
                ],
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
                 ] + (if $.dirSuffix == "slb-nginx-config-b" then [
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
    slbManifestWatcher(supportedProxies=[], deleteLimitOverride=0): {
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
                 + ["--maxDeleteLimit=" + slbconfigs.maxDeleteLimit(deleteLimitOverride)]
                 + (if slbflights.roleEnabled then [
                     "--isRoleUsed=true",
                     ] else [])
                 + (if slbimages.hyperslb_build >= 2056 then [
                     "--metricsEndpoint=" + configs.funnelVIP,
                   ] else [])
                 + [
                        "--vcioptions.strict=true",
                        "--client.allowStale=true",
                        "--control.manifestWatcherSentinel=" + mwSentinel,
                    ] + (if std.length(supportedProxies) > 0 then [
                        "--pipeline.supportedProxies=" + std.join(",", supportedProxies),
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
    } + (
        if configs.estate == "prd-sdc" then {
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
        }
        else {}
    ),
    slbNginxConfig(deleteLimitOverride=0, vipInterfaceName="", tlsConfigEnabled=false): {
        ports: [
            {
                name: "slb-nginx-port",
                containerPort: portconfigs.slb.slbNginxControlPort,
            },
        ],
        name: "slb-nginx-config",
        image: slbimages.hyperslb,
        [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
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
        ]
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
        + (if slbflights.nginxStreamlogsEnabled then [
            "--commonconfig.accessLogDirectory=" + slbconfigs.logsDir,
            "--tcpconfig.accessLogFormat=basic",
        ] else [])
        + [
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
    },
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
}
