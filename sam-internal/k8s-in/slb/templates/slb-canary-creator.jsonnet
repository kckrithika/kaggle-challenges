local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-canary-creator" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-canary-creator" };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-canary-creator",
        } + configs.ownerLabel.slb,
        name: "slb-canary-creator",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-creator",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                nodeSelector: {
                    master: "true",
                },
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary-creator",
                        image: slbimages.hypersdn,
                        [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: [
                                     "/sdn/slb-canary-creator",
                                     "--canaryImage=" + slbimages.hypersdn,
                                     "--metricsEndpoint=" + configs.funnelVIP,
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--maxParallelism=" + slbconfigs.canaryMaxParallelism,
                                 ] + (if configs.estate == "prd-sdc" then ["--podPreservationTime=5m", "--allHours=true"] else []) +  # Avoid canary preservation in SDC due to VIP exhaustion
                                 [
                                     configs.sfdchosts_arg,
                                     "--hostnameOverride=$(NODE_NAME)",
                                 ] + (if configs.estate == "fra-sam" || configs.estate == "cdg-sam" then [
                                     "--minSleepTime=2h",
                                     "--maxSleepTime=3h",
                                 ] else []),
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                            slbconfigs.node_name_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    },
                    slbshared.slbLogCleanup,
                ],
            } + slbflights.getDnsPolicy(),
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
