local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-realsvrcfg" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-realsvrcfg" }
                  + (if configs.estate == "prd-sam" then { servicesNotToLbOverride:: "" } else {});
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-realsvrcfg",
        },
        name: "slb-realsvrcfg",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-realsvrcfg",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.sbin_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.slb_config_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.proxyconfig_volume,
                ]),
                containers: [
                    slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiRealSvrOverridePort, false),
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorRealSvrLivenessProbeOverridePort, "slb-nginx-config-b", "", ""),
                    slbshared.slbCleanupConfig,
                    # Realsvrcfg currently only configures the tunnel interface for SAM apps so it does not have manifest watcher running in its pod
                    # So, it does not need to check the manifest watcher sentinel
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiRealSvrOverridePort, false),
                    slbshared.slbLogCleanup,
                ],
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                        {
                                            key: "pool",
                                            operator: "In",
                                            values: slbconfigs.perCluster.realsvrcfg_pools[configs.estate],
                                        },

                                    ],
                                },
                            ] + if configs.kingdom == "prd" then [{
                                matchExpressions: [
                                    {
                                        key: "master",
                                        operator: "In",
                                        values: ["true"],
                                    },
                                ],
                            }] else [],
                        },
                    },
                },
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: slbflights.realsvrCfgRolloutMaxUnavailable,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
