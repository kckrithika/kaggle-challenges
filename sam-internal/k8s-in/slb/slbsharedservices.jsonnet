{
    dirSuffix:: "",
    local portconfigs = import "slbports.jsonnet",
    nodeApiPort:: portconfigs.slb.slbNodeApiPort,
    configProcessorLivenessPort:: portconfigs.slb.slbConfigProcessorLivenessProbePort,
    proxyLabelSelector:: "slb-nginx-config-b",
    local configs = import "config.jsonnet",
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile },

    slbConfigProcessor: {
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
            "--processKnEConfigs=" + slbconfigs.processKnEConfigs,
            "--kneConfigDir=" + slbconfigs.kneConfigDir,
            "--kneDomainName=" + slbconfigs.kneDomainName,
            "--livenessProbePort=" + $.configProcessorLivenessPort,
            "--shouldRemoveConfig=true",
            configs.sfdchosts_arg,
            "--proxySelectorLabelValue=" + $.proxyLabelSelector,
            "--hostnameOverride=$(NODE_NAME)",
        ] + (if configs.estate == "prd-sam" then [
            "--servicesNotToLbOverride=illumio-proxy-svc,illumio-dsr-nonhost-svc,illumio-dsr-host-svc",
        ] else []),
        volumeMounts: configs.filter_empty([
            configs.maddog_cert_volume_mount,
            slbconfigs.slb_volume_mount,
            slbconfigs.slb_config_volume_mount,
            slbconfigs.logs_volume_mount,
            configs.cert_volume_mount,
            configs.kube_config_volume_mount,
            configs.sfdchosts_volume_mount,
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
                port: $.configProcessorLivenessPort,
            },
            initialDelaySeconds: 600,
            timeoutSeconds: 5,
            periodSeconds: 30,
        },
    },
    slbNodeApi: {
        name: "slb-node-api",
        image: slbimages.hypersdn,
        command: [
            "/sdn/slb-node-api",
            "--port=" + $.nodeApiPort,
            "--configDir=" + slbconfigs.configDir,
            "--log_dir=" + slbconfigs.logsDir,
        ],
        volumeMounts: configs.filter_empty([
            slbconfigs.slb_volume_mount,
            slbconfigs.logs_volume_mount,
        ]),
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
            "--skipFilesWithSuffix=slb.block",
        ] + if configs.estate == "prd-sam" then [
            # Increase maxDeleteCount so slb-cleanup will remove the -nginx-proxy config files
            "--maxDeleteFileCount=500",
        ] else [
            "--maxDeleteFileCount=20",
        ],
        volumeMounts: configs.filter_empty([
            slbconfigs.slb_volume_mount,
            slbconfigs.slb_config_volume_mount,
            slbconfigs.logs_volume_mount,
        ]),
        securityContext: {
            privileged: true,
        },
    },
    slbRealSvrCfg: {
        name: "slb-realsvrcfg",
        image: slbimages.hypersdn,
        command: [
            "/sdn/slb-realsvrcfg",
            "--configDir=" + slbconfigs.configDir,
            "--period=5s",
            "--netInterfaceName=eth0",
            "--log_dir=" + slbconfigs.logsDir,
            configs.sfdchosts_arg,
        ],
        volumeMounts: configs.filter_empty([
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
                                                            ] + (if slbimages.phase == "1" then [
                                                             "--filePath=/host/data/slb/logs/" + $.dirSuffix + "/slb-nginx-proxy.emerg.log",
                                                            ] else [
                                                              "--filePath=/host/data/slb/logs/slb-nginx-proxy.emerg.log",
                                                            ]) + [
                                                            "--metricName=nginx-emergency",
                                                            "--lastModReportTime=120s",
                                                            "--scanPeriod=10s",
                                                            "--skipZeroLengthFiles=true",
                                                            "--metricsEndpoint=" + configs.funnelVIP,
                                                            "--log_dir=" + slbconfigs.logsDir,
                                                            configs.sfdchosts_arg,
                                                        ],
                                                        volumeMounts: configs.filter_empty([
                                                            {
                                                                name: "var-target-config-volume",
                                                                mountPath: "/etc/nginx/conf.d",
                                                            },
                                                            slbconfigs.logs_volume_mount,
                                                            configs.sfdchosts_volume_mount,
                                                        ]),
                                                    },
}
