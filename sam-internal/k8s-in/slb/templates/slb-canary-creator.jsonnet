local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phase == "1" then { dirSuffix:: "slb-canary-creator" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + (if slbimages.phase == "1" then { dirSuffix:: "slb-canary-creator" } else {});
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-creator",
        },
        name: "slb-canary-creator",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-creator",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                nodeSelector: {
                    master: "true",
                },
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                ] + (if slbimages.phase == "1" then [
                    slbconfigs.slb_config_volume,
                    configs.cert_volume,
                    slbconfigs.slb_volume,
                ] else [])),
                containers: [
                    {
                        name: "slb-canary-creator",
                        image: slbimages.hypersdn,
                        command: [
                                     "/sdn/slb-canary-creator",
                                     "--canaryImage=" + slbimages.hypersdn,
                                     "--metricsEndpoint=" + configs.funnelVIP,
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--maxParallelism=" + slbconfigs.canaryMaxParallelism,
                                 ] + (if configs.estate == "prd-sdc" then ["--podPreservationTime=5m"] else []) +  # Avoid canary preservation in SDC due to VIP exhaustion
                                 [configs.sfdchosts_arg],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    },
                ] + (if slbimages.phase == "1" then [
                    slbshared.slbConfigProcessor,
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi,
                ] else []),
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
