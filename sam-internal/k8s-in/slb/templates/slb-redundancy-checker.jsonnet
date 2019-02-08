local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-redundancy-checker",
        } + configs.ownerLabel.slb,
        name: "slb-redundancy-checker",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-redundancy-checker",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ]),
                containers: [
                    {
                        name: "slb-redundancy-checker",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-redundancy-checker",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--deploymentsToMonitor=slb-ipvs,slb-nginx-config-b,slb-vip-watchdog,slb-dns-register",
                            configs.sfdchosts_arg,
                        ] + (if slbflights.kernelVersionCheckerEnabled then [
                            "--kernelVersionNodeFilter=" + slbconfigs.kernelVersionNodeFilter,
                            "--kernelVersionPrefixList=" + slbconfigs.kernelVersionPrefixList,
                        ] else []),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
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
                    },
                ],
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy()
              + slbconfigs.slbEstateNodeSelector,
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
