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
                    ]
                    +
                    (
                     if (configs.estate != "prd-sdc" && configs.estate != "prd-sam") then
                      [slbshared.slbCleanupConfig]

                  else []
                )
                + [
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
                # The rollout of slb-realsvrcfg sometimes gets stuck waiting for pod termination.
                # When this happens, we observe issues with canary DSR VIP availability.
                # See discussion at https://computecloud.slack.com/archives/G340CE86R/p1555707096410000?thread_ts=1555702827.408500&cid=G340CE86R
                # Reduce the maxUnavailable for realsvrcfg from 20% to 1, so that at most one daemonset
                # pod is offline at a time.
                maxUnavailable: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
