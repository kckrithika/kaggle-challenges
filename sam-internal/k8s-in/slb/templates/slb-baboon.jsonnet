local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-baboon" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-baboon" };
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-baboon",
        },
        name: "slb-baboon",
        namespace: "sam-system",
    },
    spec: {
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
                ]),
                containers: [
                    {
                        name: "slb-baboon",
                        image: slbimages.hypersdn,
                        command: [
                        ] + (
                            if slbimages.phase == "1" then [
                                "/sdn/slb-baboon",
                                "--k8sapiserver=",
                                "--namespace=sam-system",
                                "--log_dir=" + slbconfigs.logsDir,
                                "--hostnameoverride=$(NODE_NAME)",
                                "--port=" + portconfigs.slb.baboonEndPointPort,
                                "--metricsEndpoint=" + configs.funnelVIP,
                                "--deletePodPeriod=20m",
                                "--deleteIpvsStatePeriod=4h",
                                "--deleteConfigFilePeriod=50m",
                                "--deleteNginxTunnelIntfPeriod=2h",
                                "--deleteIpvsIntfPeriod=1.5h",
                                "--deleteCustomerPodPeriod=30m",
                                "--slbPodLabel=" + slbconfigs.podLabelList,
                                configs.sfdchosts_arg,
                                "--deletePodFlag=true",
                                "--deleteIpvsStateFlag=true",
                                "--deleteConfigFileFlag=true",
                                "--deleteNginxTunnelIntfFlag=true",
                                "--deleteIpvsIntfFlag=true",
                                "--deleteCustomerPodFlag=true",
                                "--client.serverInterface=lo",
                            ] else [
                                "/sdn/slb-baboon",
                                "--k8sapiserver=",
                                "--namespace=sam-system",
                                "--log_dir=" + slbconfigs.logsDir,
                                "--hostnameoverride=$(NODE_NAME)",
                                "--port=" + portconfigs.slb.baboonEndPointPort,
                                "--metricsEndpoint=" + configs.funnelVIP,
                                "--deletePodPeriod=2h",
                                "--deleteIpvsStatePeriod=4h",
                                "--deleteConfigFilePeriod=5h",
                                "--deleteNginxTunnelIntfPeriod=3h",
                                "--deleteIpvsIntfPeriod=1.5h",
                                "--deleteCustomerPodPeriod=7h",
                                "--slbPodLabel=" + slbconfigs.podLabelList,
                                configs.sfdchosts_arg,
                                "--deletePodFlag=true",
                                "--deleteIpvsStateFlag=false",
                                "--deleteConfigFileFlag=false",
                                "--deleteNginxTunnelIntfFlag=false",
                                "--deleteIpvsIntfFlag=false",
                                "--deleteCustomerPodFlag=false",
                                "--client.serverInterface=lo",
                            ]
                        ),
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
                    },
                    slbshared.slbConfigProcessor,
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi,
                    slbshared.slbLogCleanup,
                ],
                nodeSelector: {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    name: "slb-baboon",
                    apptype: "monitoring",
                },
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
