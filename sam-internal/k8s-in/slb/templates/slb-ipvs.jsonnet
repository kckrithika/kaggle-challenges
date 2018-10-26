local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-ipvs" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-ipvs" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-ipvs" };

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-ipvs",
        } + configs.ownerLabel.slb,
        name: "slb-ipvs",
        namespace: "sam-system",
    },
    spec+: {
        replicas: slbconfigs.ipvsReplicaCount,
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
                    (if slbflights.ipvsProcessorProxySelection then slbconfigs.proxyconfig_volume else {}),
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
                            "--maximumDeleteCount=" + slbconfigs.perCluster.maxDeleteCount[configs.estate],
                        ]
                        + [
                            configs.sfdchosts_arg,
                            "--client.serverPort=" + slbports.slb.slbNodeApiIpvsOverridePort,
                            "--client.serverInterface=lo",
                            "--metricsEndpoint=" + configs.funnelVIP,
                        ]
                        + [
                            "--httpTimeout=1s",
                            "--enablePersistence=false",
                        ] + (if slbflights.stockIpvsModules then [
                            "--sforceScheduler=false",
                        ] else [])
                        + slbconfigs.getNodeApiClientSocketSettings()
                        + [
                            // Note that current nginx config is hard-coded to rise=2, fall=5 (https://git.soma.salesforce.com/sdn/sdn/blob/assert-validation-succeeds/src/slb/slb-nginx-config/commonconfig/commonconfig.go#L147-L152).
                            "--healthcheck.riseCount=5",
                            "--healthcheck.fallCount=2",
                        ] + (if slbflights.ipvsProcessorProxySelection then [
                            "--computeProxyServers=true",
                        ] else []),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ] + (if slbflights.ipvsProcessorProxySelection then [
                             slbconfigs.proxyconfig_volume_mount,
                        ] else []))
                        + (if slbimages.hypersdn_build >= 1323 then [
                             configs.kube_config_volume_mount,
                             configs.maddog_cert_volume_mount,
                        ] else []),
                        securityContext: {
                            privileged: true,
                        },
                    } + (
                      if slbimages.hypersdn_build >= 1323 then {
                        env: [
                         configs.kube_config_env,
                        ],
                      } else {}
),
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
                                "--enableAcl=false",
                            ] else [
                            ]) +
                        [
                            "--enableConntrack=false",
                        ] + slbconfigs.getNodeApiClientSocketSettings(),
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
                    slbshared.slbManifestWatcher(),
                ],
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
               } + slbconfigs.getDnsPolicy(),
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
