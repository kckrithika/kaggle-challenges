{
    dirSuffix:: "",
    local portconfigs = import "slbports.jsonnet",
    local configs = import "config.jsonnet",
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile },
    local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },

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
                 ] + (
                     if slbimages.hypersdn_build > 1355 then [
                 ] else [
                     "--processKnEConfigs=" + slbconfigs.processKnEConfigs,
                     "--kneConfigDir=" + slbconfigs.kneConfigDir,
                     "--kneDomainName=" + slbconfigs.kneDomainName,
                     ]
                  ) + [
                     "--livenessProbePort=" + configProcessorLivenessPort,
                     "--shouldRemoveConfig=true",
                     configs.sfdchosts_arg,
                     "--proxySelectorLabelValue=" + proxyLabelSelector,
                     "--hostnameOverride=$(NODE_NAME)",
                 ] + (if configs.estate == "prd-sam" then [
                          "--servicesToLbOverride=" + servicesToLbOverride,
                          "--servicesNotToLbOverride=" + servicesNotToLbOverride,
                      ] else if $.dirSuffix == "slb-nginx-config-b" && slbflights.hsmCanaryEnabled && !slbflights.supportedProxiesEnabled then [
                          # Phase out this flag as we phase in the supported proxies
                          "--servicesNotToLbOverride=slb-canary-hsm-service",
                      ] else []) +
                 [
                     "--control.configProcSentinel=" + configProcSentinel,
                 ] + (if slbflights.supportedProxiesEnabled && std.length(supportedProxies) > 0 then [
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
            (if slbflights.supportedProxiesEnabled then slbconfigs.proxyconfig_volume_mount else {}),
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
                     "--control.sentinelExpiration=" + (if slbflights.tuneIfaceSentinelExpiration then "300s" else "120s"),
                     "--period=5s",
                     "--metricsEndpoint=" + configs.funnelVIP,
                     "--log_dir=" + slbconfigs.logsDir,
                     configs.sfdchosts_arg,
                 ] + (if slbimages.hypersdn_build >= 1355 then [] else [
                     "--readVipsFromIpvs=true",
                     "--client.serverPort=" + nodeApiPort,
                     "--client.serverInterface=lo",
                 ])
                   + (if configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1271 then [
                     "--turnDownOnSIGTERM=true",
                     ] else [])
                 + (if slbimages.hypersdn_build >= 1355 then [] else slbconfigs.getNodeApiClientSocketSettings())
                 + ["--subnet=" + slbconfigs.subnet + "," + slbconfigs.publicSubnet]
                 + (if slbimages.hypersdn_build >= 1355 then [] else ["--maxDeleteVipCount=" + slbconfigs.maxDeleteLimit(deleteLimitOverride)])
                 + (if configs.estate == "prd-sdc" && slbimages.hypersdn_build >= 1362 then ["--addIfaceIfIPVSHost=" + addIfaceIfIPVSHost] else []),
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
                    ] + (if slbflights.supportedProxiesEnabled && std.length(supportedProxies) > 0 then [
                        "--pipeline.supportedProxies=" + std.join(",", supportedProxies),
                    ] else []),
        volumeMounts: std.prune([
            slbconfigs.slb_volume_mount,
            configs.sfdchosts_volume_mount,
            configs.kube_config_volume_mount,
            configs.maddog_cert_volume_mount,
            (if slbflights.supportedProxiesEnabled then slbconfigs.proxyconfig_volume_mount else {}),
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
}
