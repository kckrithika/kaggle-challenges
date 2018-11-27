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
      supportedProxies=[]
): {
        name: "slb-config-processor",
        image: slbimages.hypersdn,
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
                     "--vipsToAcl=slb-bravo-svc.sam-system." + configs.estate + ".prd.slb.sfdc.net",
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
                    ] else []),
        volumeMounts: std.prune([
            configs.maddog_cert_volume_mount,
            slbconfigs.slb_volume_mount,
            slbconfigs.slb_config_volume_mount,
            slbconfigs.logs_volume_mount,
            configs.cert_volume_mount,
            configs.kube_config_volume_mount,
            configs.sfdchosts_volume_mount,
            slbconfigs.proxyconfig_volume_mount,
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
        image: slbimages.hypersdn,
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
        image: slbimages.hypersdn,
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
        image: slbimages.hypersdn,
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
        image: slbimages.hypersdn,
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
    slbIfaceProcessor(nodeApiPort, addIfaceIfIPVSHost, deleteLimitOverride=0): {
        name: "slb-iface-processor",
        image: slbimages.hypersdn,
        command: [
                     "/sdn/slb-iface-processor",
                     "--configDir=" + slbconfigs.configDir,
                     "--control.sentinelExpiration=300s",
                     "--period=5s",
                     "--metricsEndpoint=" + configs.funnelVIP,
                     "--log_dir=" + slbconfigs.logsDir,
                     configs.sfdchosts_arg,
                ] + (if slbflights.ipvsTurnDownOnSIGTERM then [
                     "--turnDownOnSIGTERM=true",
                     ] else [])
                 + ["--subnet=" + slbconfigs.subnet + "," + slbconfigs.publicSubnet]
                 + (if slbflights.ifaceProcessorAddIfaceIfIPVSHost then ["--addIfaceIfIPVSHost=" + addIfaceIfIPVSHost] else []),
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
        image: slbimages.hypersdn,
        command: [
                     "/sdn/slb-manifest-watcher",
                     "--manifestOutputDir=" + slbconfigs.manifestDir,
                     "--tnrpEndpoint=" + (if configs.estate == "hnd-sam" then "https://ops0-piperepo2-1-hnd.ops.sfdc.net/" else configs.tnrpEndpoint),
                     "--hostnameOverride=$(NODE_NAME)",
                     "--log_dir=" + slbconfigs.logsDir,
                     configs.sfdchosts_arg,
                 ] + slbconfigs.getNodeApiClientSocketSettings()
                 + ["--maxDeleteLimit=" + slbconfigs.maxDeleteLimit(deleteLimitOverride)]
                 + (if slbflights.roleEnabled then [
                     "--isRoleUsed=true",
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
        image: slbimages.hypersdn,
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
    slbNginxConfig(deleteLimitOverride=0, vipInterfaceName=""): {
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
                                     "--target=" + slbconfigs.nginxContainerTargetDir,
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
                                     slbconfigs.nginxReloadSentinelParam,
                                     "--httpconfig.custCertsDir=" + slbconfigs.customerCertsPath,
                                     "--checkDuplicateVips=true",
                                     "--httpconfig.accessLogFormat=main",
                                     "--commonconfig.riseCount=5",
                                     "--commonconfig.fallCount=2",
                                     "--commonconfig.healthTimeout=3000",
                                   ] + (if std.length(vipInterfaceName) > 0 then [
                                     # The default vip interface name is tunl0
                                     "--vipInterfaceName=" + vipInterfaceName,
                                   ] else []),
                          volumeMounts: configs.filter_empty([
                            slbconfigs.target_config_volume_mount,
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
    slbNginxProxy(proxyImage): {
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
                          volumeMounts: std.prune([
                            slbconfigs.nginx_config_volume_mount,
                            slbconfigs.nginx_logs_volume_mount,
                            slbconfigs.customer_certs_volume_mount,
                          ]
                          + madkub.madkubSlbCertVolumeMounts(slbconfigs.nginxCertDirs)
                          + [
                            slbconfigs.slb_volume_mount,
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
