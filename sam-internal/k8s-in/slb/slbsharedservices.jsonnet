{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile },
    local portconfigs = import "slbports.jsonnet",

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
            "--livenessProbePort=" + portconfigs.slb.slbConfigProcessorLivenessProbePort,
            "--shouldRemoveConfig=true",
            configs.sfdchosts_arg,
            "--proxySelectorLabelValue=slb-nginx-config-b",
        ],
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
        ],
        securityContext: {
            privileged: true,
        },
        livenessProbe: {
            httpGet: {
                path: "/liveness-probe",
                port: portconfigs.slb.slbConfigProcessorLivenessProbePort,
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
            "--port=" + portconfigs.slb.slbNodeApiPort,
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
}
