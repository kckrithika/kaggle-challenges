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
                volumes: std.prune([
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
                    slbconfigs.proxyconfig_volume,
                    slbconfigs.slb_kern_log_volume,
                ]),
                containers: [
                    {
                        name: "slb-ipvs-installer",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--period=5s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--IpvsPath=" + if slbimages.phaseNum <= 4 then "20191010" else "20190114",
                            configs.sfdchosts_arg,
                            "--ipvsConnTabBits=20",
                        ],
                        volumeMounts: std.prune([
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
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-ipvs-processor",
                            "--marker=" + slbconfigs.ipvsMarkerFile,
                            "--period=5s",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maximumDeleteCount=" + slbconfigs.perCluster.maxDeleteCount[configs.estate],
                            configs.sfdchosts_arg,
                            "--client.serverPort=" + slbports.slb.slbNodeApiIpvsOverridePort,
                            "--client.serverInterface=lo",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--httpTimeout=1s",
                            "--enableOnlyRunningStateProxy=true",
                        ]
                        + slbconfigs.getNodeApiClientSocketSettings()
                        + [
                            "--healthcheck.riseCount=5",
                            "--healthcheck.fallCount=2",
                            "--healthcheck.healthchecktimeout=3s",
                        ],
                        volumeMounts: std.prune([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                            slbconfigs.proxyconfig_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                        env: [
                            configs.kube_config_env,
                            slbconfigs.function_namespace_env,
                            slbconfigs.function_instance_name_env,
                        ],
                    },
                    {
                        name: "slb-ipvs-data",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-ipvs-data",
                            "--connPort=" + portconfigs.slb.ipvsDataConnPort,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: std.prune([
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
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-ipvs-conntrack",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--client.serverPort=" + slbports.slb.slbNodeApiIpvsOverridePort,
                            "--client.serverInterface=lo",
                            "--enableAcl=true",
                            "--enableConntrack=false",
                            "--enableCheckAntiDdos=true",
                            "--dropEntry=1",
                            "--dropPacket=1",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--iprange.InternalIpRange=" + slbconfigs.perCluster.internalIpRange[configs.estate],
                       ] + slbconfigs.getNodeApiClientSocketSettings(),
                        volumeMounts: std.prune([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                            slbconfigs.sbin_volume_mount,
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
                    {
                        name: "slb-cleanup-kern-logs",
                        image: slbimages.hyperslb,
                        command: [
                            "/bin/bash",
                            "/sdn/slb-cleanup-log.sh",
                            "/var/log/kern.*",
                            "3600",
                        ],
                        volumeMounts: std.prune([
                            slbconfigs.slb_kern_log_volume_mount,
                        ]),
                    },
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
               } + slbconfigs.getGracePeriod()
                 + slbconfigs.getDnsPolicy(),
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 60,
    },
} else "SKIP"
