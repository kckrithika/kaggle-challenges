local configs = import "config.jsonnet";
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-labels-checker" };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-labels-checker" };
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-labels-checker" };

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-labels-checker",
        } + configs.ownerLabel.slb,
        name: "slb-labels-checker",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.cleanup_logs_volume,
                ]),
                containers: std.prune([
                    {
                        name: "slb-labels-checker",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-labels-checker",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            configs.sfdchosts_arg,
                        ] + if configs.estate == "prd-sdc" then [
                            "--labelValues=slb-ipvs:2,slb-nginx-b:2",
                        ] else [
                            "--labelValues=slb-ipvs:3,slb-nginx-b:3",
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                            {
                                name: "NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                    slbshared.slbLogCleanup,
                ]),
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy()
              + slbconfigs.slbEstateNodeSelector,
            metadata: {
                labels: {
                    name: "slb-labels-checker",
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
