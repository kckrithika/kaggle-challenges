local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbports = import "slbports.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + (if slbimages.phaseNum == 1 then { dirSuffix:: "slb-nginx-data-watchdog" } else {});
local slbshared = (import "slbsharedservices.jsonnet") + (if slbimages.phaseNum == 1 then { dirSuffix:: "slb-nginx-data-watchdog" } else {});

if slbimages.phaseNum == 1 || (slbimages.hypersdn_build > 1122 && slbconfigs.slbInKingdom) then configs.deploymentBase("slb") {
    metadata+: {
        labels: {
            name: "slb-nginx-data-watchdog",
        } + configs.ownerLabel.slb,
        name: "slb-nginx-data-watchdog",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                                                  configs.maddog_cert_volume,
                                                  slbconfigs.slb_volume,
                                                  slbconfigs.logs_volume,
                                                  configs.cert_volume,
                                                  configs.kube_config_volume,
                                                  configs.sfdchosts_volume,
                                              ]
                                              + (
                                                  if slbimages.phaseNum == 1 then [
                                                      slbconfigs.slb_config_volume,
                                                      slbconfigs.cleanup_logs_volume,
                                                  ] else []
                                              )),
                containers: [
                                {
                                    name: "slb-nginx-data-watchdog",
                                    image: slbimages.hypersdn,
                                    command: [
                                                 "/sdn/slb-nginx-data-watchdog",
                                                 "--namespace=sam-system",
                                                 configs.sfdchosts_arg,
                                                 "--k8sapiserver=",
                                                 "--connPort=" + slbports.slb.nginxDataConnPort,
                                                 "--monitorFrequency=180s",
                                                 "--nginxWDmetricsEndpoint=" + configs.funnelVIP,
                                                 "--nginxWDhostnameOverride=$(NODE_NAME)",
                                             ],

                                    volumeMounts: configs.filter_empty(
[
                                                                           configs.maddog_cert_volume_mount,
                                                                           slbconfigs.slb_volume_mount,
                                                                           slbconfigs.logs_volume_mount,
                                                                           configs.cert_volume_mount,
                                                                           configs.kube_config_volume_mount,
                                                                           configs.sfdchosts_volume_mount,
                                                                       ]
                                                                       + (
                                                                           if slbimages.phaseNum == 1 then [
                                                                               slbconfigs.slb_config_volume_mount,
                                                                           ] else []
                                                                       )
),
                                    env: [
                                        slbconfigs.node_name_env,
                                        configs.kube_config_env,
                                    ],
                                },

                            ]
                            + (
                                if slbimages.phaseNum == 1 then [
                                    slbshared.slbCleanupConfig,
                                    slbshared.slbLogCleanup,
                                ] else []
                            ),
            } + (
                if slbconfigs.isTestEstate then { nodeSelector: { pool: configs.estate } } else { nodeSelector: { pool: configs.kingdom + "-slb" } }
            ),
            metadata: {
                labels: {
                    name: "slb-nginx-data-watchdog",
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
