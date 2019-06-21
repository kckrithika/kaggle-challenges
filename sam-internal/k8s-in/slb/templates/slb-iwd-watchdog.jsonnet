local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-iwd-health" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-iwd-health" };

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
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
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    slbconfigs.slb_config_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-iwd-health",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-iwd-health",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--k8sapiserver=",
                            "--deploymentsToMonitor=slb-ipvs:" + slbconfigs.ipvsReplicaCount + ",slb-nginx-config-b:" + slbconfigs.nginxConfigReplicaCount,
                            "--minPercentHealthy=" + 1,
                        ],
                    },
                    slbshared.slbLogCleanup,
                ],

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
