local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-iwd-health" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-iwd-health" };

if slbconfigs.isSlbEstate && slbflights.enableIWDHealth then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-iwd-health",
        },
        name: "slb-iwd-health",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-iwd-health",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    slbconfigs.slb_config_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-iwd-health",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-iwd-health",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--k8sAPIServer=",
                            "--deploymentsToMonitor=slb-ipvs=" + slbconfigs.ipvsReplicaCount + ",slb-nginx-config-b=" + slbconfigs.nginxConfigReplicaCount,
                            "--minPercentHealthy=" + 1,
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        env: [
                            slbconfigs.node_name_env,
                            configs.kube_config_env,
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
                nodeSelector: {
                    pool: slbconfigs.slbEstate,
                },
            } + slbconfigs.getGracePeriod()
            + slbconfigs.getDnsPolicy(),
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "20%",
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
