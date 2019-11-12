local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-iface-processor" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-iface-processor" };
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-iface-processor",
        },
        name: "slb-iface-processor",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-iface-processor",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.sbin_volume,
                    configs.cert_volume,
                    slbconfigs.cleanup_logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    slbconfigs.proxyconfig_volume,
                ]),
                containers: [
                    slbshared.slbIfaceProcessor(slbports.slb.slbNodeApiIfaceOverridePort),
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorIfaceLivenessProbeOverridePort),
                    ]

                    + (
                  if (configs.estate != "prd-sdc") then
                      [slbshared.slbCleanupConfig]

                  else []
                )
                + [
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiIfaceOverridePort, false),
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
                                            values: [slbconfigs.slbEstate],
                                        },

                                    ],
                                },
                            ] + if slbconfigs.isTestEstate then [{
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
                maxUnavailable: "20%",
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
