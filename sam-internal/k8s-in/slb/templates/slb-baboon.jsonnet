local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-baboon" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-baboon" };
local portconfigs = import "slbports.jsonnet";
local slbflights = import "slbflights.jsonnet";

if (slbconfigs.isTestEstate || configs.estate == "prd-sam") && configs.estate != "prd-sdc" && configs.estate != "prd-samtest" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-baboon",
        } + configs.ownerLabel.slb,
        name: "slb-baboon",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    {
                        hostPath: {
                            path: "/usr/bin/kubectl",
                        },
                        name: "kubectl",
                    },
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.proxyconfig_volume,
                ]),
                containers: [
                    {
                        name: "slb-baboon",
                        image: slbimages.hyperslb,
                        command: [
                                "/sdn/slb-baboon",
                                "--k8sapiserver=",
                                "--podNamespace=sam-system",
                                "--log_dir=" + slbconfigs.logsDir,
                                "--hostnameoverride=$(NODE_NAME)",
                                "--port=" + portconfigs.slb.baboonEndPointPort,
                                "--metricsEndpoint=" + configs.funnelVIP,
                                "--deletePodPeriod=1h",
                                "--deleteIpvsStatePeriod=4h",
                                "--deleteConfigFilePeriod=4.5h",
                                "--deleteNginxTunnelIntfPeriod=2h",
                                "--deleteIpvsIntfPeriod=1.5h",
                                "--deleteBackendPodPeriod=3h",
                                "--slbPodLabel=" + slbconfigs.podLabelList,
                                configs.sfdchosts_arg,
                                "--deletePodFlag=true",
                                "--deleteIpvsStateFlag=false",
                                "--deleteConfigFileFlag=true",
                                "--deleteNginxTunnelIntfFlag=true",
                                "--deleteIpvsIntfFlag=true",
                                "--deleteBackendPodFlag=true",
                                "--client.serverInterface=lo",
                                "--chaosDeletePodFlag=true",
                                "--chaosPodLabel=chaos.sfdc.net/podDelete=true",
                                "--chaosPodNamespace=user-jhankins",
                        ] + slbconfigs.getNodeApiClientSocketSettings(),
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            {
                                name: "kubectl",
                                mountPath: "/usr/bin/kubectl",
                            },
                            configs.sfdchosts_volume_mount,
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
                    } + configs.ipAddressResourceRequest,
                    slbshared.slbConfigProcessor(portconfigs.slb.slbConfigProcessorLivenessProbePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi(portconfigs.slb.slbNodeApiPort, false),
                    slbshared.slbLogCleanup,
                ],
                nodeSelector: {
                    master: "true",
                },
                dnsPolicy: "Default",
            } + slbconfigs.getGracePeriod(),
            metadata: {
                labels: {
                    name: "slb-baboon",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
