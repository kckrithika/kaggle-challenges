local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-ipvs" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-ipvs" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-ipvs" };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-ipvs",
        } + configs.ownerLabel.slb,
        name: "slb-ipvs",
        namespace: "sam-system",
    },
    spec+: {
        replicas: if configs.estate == "prd-samtest" then 1 else if slbconfigs.slbInProdKingdom || configs.estate == "prd-sam" then 3 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-ipvs",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    {
                        name: "dev-volume",
                        hostPath: {
                            path: "/dev",
                        },
                    },
                    {
                        name: "lib-modules-volume",
                        hostPath: {
                            path: "/lib/modules",
                        },
                    },
                    {
                        name: "tmp-volume",
                        hostPath: {
                            path: "/tmp",
                        },
                    },
                    slbconfigs.usr_sbin_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    slbconfigs.sbin_volume,
                    slbconfigs.cleanup_logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-ipvs-installer",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--period=5s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                        ] + (if slbflights.stockIpvsModules then [
                                "--IpvsPath=stock",
                                "--IpvsSchedModule=ip_vs_sh",
                            ] else [
                                "--IpvsPath=20180910",
                            ]) +
                        [
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "dev-volume",
                                mountPath: "/dev",
                            },
                            {
                                name: "lib-modules-volume",
                                mountPath: "/lib/modules",
                            },
                            {
                                name: "tmp-volume",
                                mountPath: "/host/tmp",
                            },
                            {
                                name: "lib-modules-volume",
                                mountPath: "/host/lib/modules",
                            },
                            slbconfigs.usr_sbin_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            securityContext: {
                                privileged: true,
                            },
                        } else {
                            securityContext: {
                                privileged: true,
                                capabilities: {
                                    add: [
                                        "ALL",
                                    ],
                                },
                            },
                        }
                    ),

                    {
                        name: "slb-ipvs-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-processor",
                            "--marker=" + slbconfigs.ipvsMarkerFile,
                            "--period=5s",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maximumDeleteCount=20",
                            configs.sfdchosts_arg,
                            "--client.serverPort=" + slbports.slb.slbNodeApiIpvsOverridePort,
                            "--client.serverInterface=lo",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--proxyHealthChecks=true",
                            "--httpTimeout=1s",
                            "--enablePersistence=false",
                        ] + (
                            if configs.estate == "prd-sam" then [
                                  "--maximumDeleteCount=10",
                                  ] else []
                              ) + (if slbflights.stockIpvsModules then [
                            "--sforceScheduler=false",
                            ] else []) + slbflights.getNodeApiClientSocketSettings(slbconfigs.configDir)
                            + slbflights.getIPVSHealthCheckRiseFallSettings(),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },

                    {
                        name: "slb-ipvs-data",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-data",
                            "--connPort=" + portconfigs.slb.ipvsDataConnPort,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                        ports: [
                            {
                                containerPort: portconfigs.slb.slbIpvsControlPort,
                            },
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: portconfigs.slb.ipvsDataConnPort,
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 3,
                        },
                    },
                    {
                        name: "slb-ipvs-conntrack",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-conntrack",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--client.serverPort=" + slbports.slb.slbNodeApiIpvsOverridePort,
                            "--client.serverInterface=lo",
                        ] + (if configs.estate == "prd-sdc" then [
                                "--enableAcl=true",
                            ] else [
                            ]) +
                        [
                            "--enableConntrack=false",
                        ] + slbflights.getNodeApiClientSocketSettings(slbconfigs.configDir),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorIpvsLivenessProbeOverridePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiIpvsOverridePort, true),
                    slbshared.slbIfaceProcessor(slbports.slb.slbNodeApiIpvsOverridePort),
                    slbshared.slbLogCleanup,
                ] + slbflights.getManifestWatcherIfEnabled(),
                nodeSelector: {
                    "slb-service": "slb-ipvs",
                },
                    affinity: {
                        podAntiAffinity: {
                            requiredDuringSchedulingIgnoredDuringExecution: [{
                                labelSelector: {
                                    matchExpressions: [{
                                        key: "name",
                                        operator: "In",
                                        values: [
                                            "slb-ipvs",
                                        ],
                                    }],
                                },
                                topologyKey: "kubernetes.io/hostname",
                            }],
                        },
                        nodeAffinity: {
                            requiredDuringSchedulingIgnoredDuringExecution: {
                                nodeSelectorTerms: [{
                                    matchExpressions: [{
                                        key: "slb-service",
                                        operator: "In",
                                        values: ["slb-ipvs"],
                                    }],
                                }],
                            },
                        },
                    },
               } + slbflights.getDnsPolicy(),
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 120,
    },
} else "SKIP"
